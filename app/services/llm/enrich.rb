# frozen_string_literal: true

module Llm
  class Enrich
    class UnsupportedWordType < StandardError; end

    attr_reader :word, :word_llm_enrichment

    delegate :full_prompt, to: :llm_invocation

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

    def supported?
      response_model.present?
    rescue UnsupportedWordType
      false
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
      @llm_respponse ||= llm_invocation.call
    end

    def llm_invocation
      @llm_invocation ||= Invoke.new(
        response_model:,
        prompt_variables: {
          attributes: word.to_json
        },
        prompt: <<~PROMPT
          The following JSON includes all the information we have about the German word '#{word.name}'. Please correct and enrich that information. We use your response for students learning German. Please ensure that all your answers are in German and adhere to German grammar rules.

          {attributes}

          {format_instructions}
        PROMPT
      )
    end

    def create_enriched_attributes(response)
      ActiveRecord::Base.transaction do
        response.with_indifferent_access.slice(*response_model.properties).each do |attribute_name, value|
          next if word.send(attribute_name) == value
          next if WordAttributeEdit.exists?(word:, attribute_name:, value:)

          change_group = ChangeGroup.create!(
            state: value.present? ? :waiting_for_review : :invalid
          )

          WordAttributeEdit.create!(
            change_group:,
            word:,
            attribute_name:,
            value:
          )
        end
      end
    end

    def response_model
      case word.type
      when "Noun" then Schema::Noun
      else raise UnsupportedWordType, "Word type '#{word.type}' is not supported for LLM enrichment"
      end
    end
  end
end
