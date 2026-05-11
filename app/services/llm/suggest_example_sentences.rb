# frozen_string_literal: true

module Llm
  class SuggestExampleSentences
    attr_reader :word

    def initialize(word:)
      @word = word
    end

    def call
      raise "No active LLM service" unless LlmService.active.present?

      prompt = LlmPrompt.find_by(identifier: "example_sentences")
      raise "LLM prompt 'example_sentences' not found" unless prompt

      invoke = Invoke.new(
        prompt: prompt.content,
        prompt_variables: {
          word: word.name,
          word_type: word.class.model_name.human,
          meaning: word.meaning.presence || "",
          topics: word.topics.map(&:name).join(", "),
          existing_sentences: word.example_sentences.join("; "),
          has_image: word.image.attached? ? "Ja" : "Nein"
        },
        response_model: Schema::ExampleSentencesSuggestion,
        include_format_instructions: false
      )

      invoke.call
    end
  end
end
