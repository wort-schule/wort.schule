# frozen_string_literal: true

module Llm
  class CheckBaseForm
    include InvocationTracker

    attr_reader :name, :topic, :word_type

    def initialize(name:, topic:, word_type:)
      @name = name
      @topic = topic
      @word_type = word_type
    end

    def call
      track_invocation(key: [name, topic, word_type].join("#"), invocation_type: :check_base_form) do
        initialize_new_word_reviewable(llm_response)
      end
    end

    private

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
