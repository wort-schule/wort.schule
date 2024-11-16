# frozen_string_literal: true

module Import
  class Word
    attr_reader :name, :topic, :word_type, :word_import

    def initialize(name:, topic:, word_type:)
      @name = name
      @topic = topic
      @word_type = word_type
    end

    def call
      return if import_exists?

      create_word_import

      existing_words&.each do |existing_word|
        Llm::Enrich.new(word: existing_word).call
      end
    rescue => e
      word_import&.update(error: e.full_message)
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

    def existing_words
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
