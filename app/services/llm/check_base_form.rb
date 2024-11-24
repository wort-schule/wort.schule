# frozen_string_literal: true

module Llm
  class CheckBaseForm
    attr_reader :name, :topic, :word_type, :word_llm_invocation

    def initialize(name:, topic:, word_type:)
      @name = name
      @topic = topic
      @word_type = word_type
    end

    def call
      return if pending_llm_response?

      initialize_word_llm_invocation
      response = llm_response
      word_llm_invocation.update!(state: :completed)

      initialize_new_word_reviewable(response)
    rescue => e
      word_llm_invocation&.update!(
        state: :failed,
        error: e.full_message
      )

      raise e if word_llm_invocation.blank?
    end

    private

    def pending_llm_response?
      WordLlmInvocation
        .exists?(
          key: [name, topic, word_type].join("#"),
          invocation_type: "check_base_form",
          state: %w[new invoked]
        )
    end

    def initialize_word_llm_invocation
      @word_llm_invocation ||= WordLlmInvocation
        .create!(
          key: [name, topic, word_type].join("#"),
          invocation_type: "check_base_form",
          state: :invoked
        )
    end

    def llm_response
      @llm_response ||= Invoke.new(
        response_model: Schema::BaseForm,
        prompt_variables: {
          name:,
          topic:
        },
        prompt: <<~PROMPT
          You are a German linguist creating a dictionary of the German language. Your dictionary is praised for its correctness and accuracy. To create that dictionary you receive a word and a corresponding topic. You need to ensure that the words are in their correct base form and the topic fits the word.

          What is the base form of the word "{name}" and does the topic "{topic}" describe it well? Please answer with the input if they are correct or answer with the correct values if the input is incorrect.

          Please only answer in the format described below.

          {format_instructions}
        PROMPT
      ).call
    end

    def to_json
      {
        base_form: name,
        topic:
      }.to_json
    end

    def initialize_new_word_reviewable(response)
      NewWord.new(
        name:,
        topic:,
        word_type:,
        llm_name: response.with_indifferent_access[:base_form],
        llm_topic: response.with_indifferent_access[:topic]
      )
    end
  end
end
