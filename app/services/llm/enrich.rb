# frozen_string_literal: true

module Llm
  class Enrich
    ATTRIBUTE_GROUPS = [
      [:case_1_singular, :case_2_singular, :case_3_singular, :case_4_singular, :case_1_plural, :case_2_plural, :case_3_plural, :case_4_plural],
      [:imperative_singular, :imperative_plural],
      [:participle, :past_participle],
      [:perfect_haben, :perfect_sein],
      [:present_singular_1, :present_singular_2, :present_singular_3, :present_plural_1, :present_plural_2, :present_plural_3],
      [:past_singular_1, :past_singular_2, :past_singular_3, :past_plural_1, :past_plural_2, :past_plural_3],
      [:comparative, :superlative]
    ]

    attr_reader :word, :word_llm_invocation

    def initialize(word:)
      @word = word
      @llm_invoke_all_properties = Invoke.new(
        include_format_instructions: false,
        response_model: all_properties_response_model,
        prompt_variables: {
          input_dataset: all_properties_response_model.from_word(word).to_json,
          meaning: word.meaning,
          topics: word.topics.map(&:name).join(", ")
        },
        prompt: LlmPrompt.find_by(identifier: "all_properties").content
      )
      @llm_invoke_keywords = Invoke.new(
        include_format_instructions: false,
        response_model: keywords_response_model,
        prompt_variables: {
          word: word.name,
          valid_keywords: Word.where(id: Keyword.distinct.pluck(:keyword_id)).pluck(:name).join(", "),
          meaning: word.meaning,
          topics: word.topics.map(&:name).join(", ")
        },
        prompt: LlmPrompt.find_by(identifier: "keywords").content
      )
    end

    def call
      return if pending_llm_response?

      initialize_word_llm_invocation

      if @llm_invoke_all_properties.full_prompt.present?
        response = all_properties_llm_response
        create_enriched_attributes(response, all_properties_response_model)
      end

      if @llm_invoke_keywords.full_prompt.present?
        response = keywords_llm_response
        create_enriched_attributes(response, keywords_response_model)
      end

      word_llm_invocation.update!(state: :completed)
    rescue => e
      word_llm_invocation&.update!(
        state: :failed,
        error: e.full_message
      )

      raise e if word_llm_invocation.blank?
    end

    def supported?
      all_properties_response_model.present?
    rescue Llm::Attributes::UnsupportedWordType
      false
    end

    def full_prompts
      [
        @llm_invoke_all_properties.full_prompt,
        @llm_invoke_keywords.full_prompt
      ]
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

    def all_properties_llm_response
      @llm_invoke_all_properties.call.reject { |key, _| key.to_s == "keywords" }
    end

    def keywords_llm_response
      @llm_invoke_keywords.call
    end

    def all_properties_response_model
      Llm::Attributes.response_model(word.type)
    end

    def keywords_response_model
      Llm::Schema::Keywords
    end

    def create_enriched_attributes(response, response_model)
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
          attributes = attributes.map do |attribute_name, value|
            existing_value = word.send(attribute_name)
            next if existing_value == value
            next if value.is_a?(ActiveSupport::HashWithIndifferentAccess)
            next if existing_value.is_a?(ActiveRecord::Base) && value == existing_value.name
            next if WordAttributeEdit.exists?(word:, attribute_name:, value:)

            if existing_value.is_a?(ActiveRecord::Relation)
              value = Attributes.filter(response_model:, attribute_name:, value:)

              next if value.blank?
              next if value.sort == existing_value.map(&:name).sort
            end

            [attribute_name, value]
          end.compact

          next if attributes.empty?

          change_group = ChangeGroup.create!(
            state: :waiting_for_review
          )

          attributes.each do |attribute_name, value|
            Rails.logger.info "Create LLM suggestion word=#{word.name} attribute_name=#{attribute_name} value=#{value}"

            WordAttributeEdit.create!(
              change_group:,
              word:,
              attribute_name:,
              value: value.to_json
            )
          end
        end
      end
    end
  end
end
