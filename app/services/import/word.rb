# frozen_string_literal: true

module Import
  class Word
    attr_reader :name, :topic, :word_type, :word_import

    def initialize(name:, topic:, word_type:, word_import_id:)
      @name = name.strip
      @topic = topic.strip
      @word_type = word_type
      @word_import = WordImport.find_by(id: word_import_id)
    end

    def call
      return if word_import.blank?
      return if [word_type, name].any?(&:blank?)

      # Only check for existing words if topic is provided
      if topic.present? && existing_words(name:, topic:).present?
        Rails.logger.info("Word exists, starting enrichment. name=#{name} topic=#{topic} word_type=#{word_type}")
        existing_words(name:, topic:).each do |existing_word|
          Llm::Enrich.new(word: existing_word).call
        end

        process_unlisted_keywords_for_existing_word(existing_words(name:, topic:).first)

        @word_import.update!(state: :completed)
        return
      end

      new_word = Llm::CheckBaseForm.new(name:, topic:, word_type:).call
      change_group = ChangeGroup.new
      new_word.change_group = change_group

      change_group.state = if new_word.llm_topic.present? && existing_words(name: new_word.llm_name, topic: new_word.llm_topic).present?
        Rails.logger.info("New word, but exists after LLM corrections. name=#{name} topic=#{topic} word_type=#{word_type} llm_name=#{new_word.llm_name} llm_topic=#{new_word.llm_topic}")
        :discarded
      else
        Rails.logger.info("New word, ready for review. name=#{name} topic=#{topic} word_type=#{word_type} llm_name=#{new_word.llm_name} llm_topic=#{new_word.llm_topic}")
        :waiting_for_review
      end

      ActiveRecord::Base.transaction do
        change_group.save!
        new_word.save!
        UnlistedKeyword.unprocessed.where(word_import:).update_all(new_word_id: new_word.id)
        @word_import.update!(state: :completed)
      end
    rescue => e
      word_import&.update(
        error: e.full_message,
        state: :failed
      )
    end

    private

    def process_unlisted_keywords_for_existing_word(existing_word)
      unlisted_keywords = UnlistedKeyword.unprocessed.where(word_import:).includes(:word).to_a
      return if unlisted_keywords.empty?

      ActiveRecord::Base.transaction do
        # Batch update all words' keywords at once
        word_ids = unlisted_keywords.map(&:word_id).uniq
        ::Word.where(id: word_ids).find_each do |word|
          word.keywords << existing_word unless word.keywords.include?(existing_word)
          word.save!
        end

        # Batch update all unlisted keywords to processed
        UnlistedKeyword.where(id: unlisted_keywords.map(&:id)).update_all(state: "processed")
      end
    end

    def existing_words(name:, topic:)
      ::Word
        .joins(:topics)
        .where(
          name:,
          type: word_type,
          "topics.name": topic
        )
    end
  end
end
