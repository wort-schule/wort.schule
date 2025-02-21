# frozen_string_literal: true

module Llm
  class Invoke
    attr_reader :prompt, :prompt_variables, :response_model, :include_format_instructions, :model

    def initialize(prompt:, prompt_variables:, response_model:, include_format_instructions: true, model: default_model)
      @prompt = prompt
      @prompt_variables = prompt_variables
      @response_model = response_model
      @include_format_instructions = include_format_instructions
      @model = model
    end

    def call
      llm_response = client.chat(
        messages: [{role: "user", content: full_prompt}]
      ).chat_completion

      raise "LLM response is empty full_prompt=#{full_prompt}" if llm_response.blank?

      Rails.logger.info "Received LLM response:\n#{llm_response}"

      text = llm_response
      json = text.include?("```") ? text.strip.split(/```(?:json)?/)[1] : text.strip
      JSON.parse(json)
    end

    def full_prompt
      return @full_prompt if defined?(@full_prompt)

      templated_prompt = Langchain::Prompt::PromptTemplate.new(
        template: prompt,
        input_variables: prompt_variables.keys.map(&:to_s) + (include_format_instructions ? ["format_instructions"] : [])
      )

      templated_prompt.format(
        format_instructions: output_parser.get_format_instructions,
        **prompt_variables
      )
    end

    private

    def client
      @client ||= Langchain::LLM::Ollama.new(
        url: ENV["OLLAMA_URL"].presence || "http://localhost:11434",
        default_options: {temperature: 0.0, chat_model: model}
      )
    end

    def default_model
      ENV["LLM_MODEL"].presence || "llama3.1"
    end

    def output_parser
      @output_parser ||= Langchain::OutputParsers::StructuredOutputParser.from_json_schema(response_model.json_schema)
    end
  end
end
