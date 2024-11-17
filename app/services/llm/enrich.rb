# frozen_string_literal: true

module Llm
  class Enrich
    attr_reader :word, :word_llm_enrichment

    def initialize(word:)
      @word = word
    end

    def call
      return if pending_llm_response?

      initialize_word_llm_enrichment
      response = llm_response
      create_enriched_attributes(response)
      word_llm_enrichment.update!(state: :completed)
    rescue => e
      word_llm_enrichment&.update!(
        state: :failed,
        error: e.full_message
      )

      raise e if word_llm_enrichment.blank?
    end

    private

    def pending_llm_response?
      WordLlmEnrichment
        .exists?(
          word:,
          state: %w[new invoked]
        )
    end

    def initialize_word_llm_enrichment
      @word_llm_enrichment ||= WordLlmEnrichment
        .create!(
          word:,
          state: :invoked
        )
    end

    def llm_response
      @llm_respponse ||= Invoke.new(
        response_model:,
        prompt_variables: {
          attributes: word.to_json
        },
        prompt: <<~PROMPT
          The following JSON includes all the information we have about the German word '#{word.name}'. Please correct and enrich that information. We use your response for students learning German. Please ensure that all your answers are in German and adhere to German grammar rules.

          {attributes}

          {format_instructions}
        PROMPT
      ).call
    end

    def create_enriched_attributes(response)
      ActiveRecord::Base.transaction do
        response.with_indifferent_access.slice(*response_model.properties).each do |attribute_name, value|
          next if word.send(attribute_name) == value

          WordAttributeEdit
            .find_or_create_by!(
              word:,
              attribute_name:,
              value:,
              state: value.present? ? :waiting_for_review : :invalid
            )
        end
      end
    end

    def response_model
      case word.type
      when "Noun" then Schema::Noun
      else raise "Word type '#{word.type}' is not supported for LLM enrichment"
      end
    end
  end
end
