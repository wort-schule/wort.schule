# frozen_string_literal: true

module Llm
  class Enrich
    ATTRIBUTE_GROUPS = [
      [:case_1_singular, :case_1_plural, :case_2_singular, :case_2_plural, :case_3_singular, :case_3_plural, :case_4_singular, :case_4_plural],
      [:imperative_singular, :imperative_plural],
      [:participle, :past_participle],
      [:perfect_haben, :perfect_sein],
      [:present_singular_1, :present_singular_2, :present_singular_3, :present_plural_1, :present_plural_2, :present_plural_3],
      [:past_singular_1, :past_singular_2, :past_singular_3, :past_plural_1, :past_plural_2, :past_plural_3],
      [:comparative, :superlative]
    ]

    attr_reader :word, :word_llm_invocation

    delegate :full_prompt, to: :llm_invocation

    def initialize(word:)
      @word = word
    end

    def call
      return if pending_llm_response?

      initialize_word_llm_invocation
      response = llm_response
      create_enriched_attributes(response)
      word_llm_invocation.update!(state: :completed)
    rescue => e
      word_llm_invocation&.update!(
        state: :failed,
        error: e.full_message
      )

      raise e if word_llm_invocation.blank?
    end

    def supported?
      response_model.present?
    rescue Llm::Attributes::UnsupportedWordType
      false
    end

    private

    def pending_llm_response?
      WordLlmInvocation
        .exists?(
          key: "#{word.class}##{word.id}",
          invocation_type: "enrichment",
          state: %w[new invoked]
        )
    end

    def initialize_word_llm_invocation
      @word_llm_invocation ||= WordLlmInvocation
        .create!(
          key: "#{word.class}##{word.id}",
          invocation_type: :enrichment,
          state: :invoked
        )
    end

    def llm_response
      @llm_respponse ||= llm_invocation.call
    end

    def llm_invocation
      @llm_invocation ||= Invoke.new(
        include_format_instructions: true,
        response_model:,
        prompt_variables: {
          input_dataset: response_model.from_word(word).to_json,
          word: word.name
        },
        prompt: <<~PROMPT
          The following JSON includes all the information we have about the German word '{word}'. Please correct and enrich that information. We use your response for students learning German. Please ensure that all your answers are in German and adhere to German grammar rules. You can use the provided JSON as an input, but please answer in a JSON conforming to the JSON schema provided later in this request.

          {input_dataset}

          {format_instructions}
        PROMPT
      )
    end

    def response_model
      Llm::Attributes.response_model(word.type)
    end

    def create_enriched_attributes(response)
      ActiveRecord::Base.transaction do
        properties = response.with_indifferent_access.slice(*response_model.properties)

        groups = ATTRIBUTE_GROUPS.map do |attributes|
          group_attributes = properties.slice(*attributes)

          properties.reject! { |property| attributes.include?(property.to_sym) }

          group_attributes
        end

        properties.each do |attribute_name, value|
          groups << {
            attribute_name => value
          }
        end

        groups.each do |attributes|
          attributes.select! do |attribute_name, value|
            next false if word.send(attribute_name) == value
            next false if WordAttributeEdit.exists?(word:, attribute_name:, value:)

            true
          end

          next if attributes.empty?

          change_group = ChangeGroup.create!(
            state: :waiting_for_review
          )

          attributes.each do |attribute_name, value|
            filtered_value = Attributes.filter(response_model:, attribute_name:, value:)
            next if filtered_value.nil?

            WordAttributeEdit.create!(
              change_group:,
              word:,
              attribute_name:,
              value: filtered_value
            )
          end
        end
      end
    end
  end
end
