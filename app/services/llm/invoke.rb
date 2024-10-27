# frozen_string_literal: true

module Llm
  class Invoke
    attr_reader :prompt, :response_model

    def initialize(prompt:, response_model:)
      @prompt = prompt
      @response_model = response_model
    end

    def call
      client.chat(
        parameters: {
          model: ENV["LLM_MODEL"].presence || "llama3.1",
          messages: [{role: "user", content: prompt}]
        },
        response_model:
      )
    end

    private

    def client
      @client ||= Instructor.from_openai(OpenAI::Client).new
    end
  end
end
