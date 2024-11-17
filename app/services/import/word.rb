# frozen_string_literal: true

module Import
  class Word
    attr_reader :name, :topic, :word_type, :word_import

    def initialize(name:, topic:, word_type:)
      @name = name.strip
      @topic = topic.strip
      @word_type = word_type
    end

    def call
      return if import_exists?

      create_word_import

      if existing_words(name:, topic:).present?
        Rails.logger.info("Word exists, starting enrichment. name=#{name} topic=#{topic} word_type=#{word_type}")
        existing_words(name:, topic:).each do |existing_word|
          Llm::Enrich.new(word: existing_word).call
        end

        return
      end

      new_word = Llm::CheckBaseForm.new(name:, topic:, word_type:).call
      change_group = ChangeGroup.new
      new_word.change_group = change_group

      change_group.state = if existing_words(name: new_word.llm_name, topic: new_word.llm_topic).present?
        Rails.logger.info("New word, but exists after LLM corrections. name=#{name} topic=#{topic} word_type=#{word_type} llm_name=#{new_word.llm_name} llm_topic=#{new_word.llm_topic}")
        :discarded
      else
        Rails.logger.info("New word, ready for review. name=#{name} topic=#{topic} word_type=#{word_type} llm_name=#{new_word.llm_name} llm_topic=#{new_word.llm_topic}")
        :waiting_for_review
      end

      ActiveRecord::Base.transaction do
        change_group.save!
        new_word.save!
        @word_import.update!(state: :completed)
      end
    rescue => e
      word_import&.update(
        error: e.full_message,
        state: :failed
      )
    end

    private

    def import_exists?
      WordImport
        .where.not(state: :failed)
        .exists?(name:, topic:, word_type:)
    end

    def create_word_import
      @word_import ||= WordImport.create!(name:, topic:, word_type:, state: :new)
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
