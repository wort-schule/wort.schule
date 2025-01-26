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

    ALL_PROPERTIES_PROMPT = <<~PROMPT
      You are a highly skilled and knowledgeable German teacher, as well as a native speaker, specializing in teaching children aged 6 to 10 how to write in the German language. Your task is to analyze, correct, and enrich a dataset containing partial information about German words, their meanings, and their grammar properties. Your goal is to suggest values for missing information, correct any existing inaccuracies, and improve the overall quality of the dataset.
      Below is a structured dataset in JSON format. This dataset may contain incomplete or incorrect information. Your role is to complete, correct, and enrich the dataset while adhering strictly to the provided JSON schema and maintaining the integrity of the content.

      Input Dataset:
      {input_dataset}

      ### Field Explanations
      Here are detailed explanations of key fields in the dataset to help you understand their purpose:

      - **`meaning`**: A short description of the word's meaning in German.
      - **`meaning_long`**: A more detailed explanation of the word, if applicable.
      - **`syllables`**: The breakdown of the word into its syllables. Each syllable should be separated by a hyphen (e.g., "Abendbrot" → "A-bend-brot").
      - **`written_syllables`**: Indicates how the word's syllables are written when teaching young learners. It may involve annotations for emphasis.
      - **`plural`**: The plural form of the word, if applicable.
      - **`compound`**: Boolean indicating whether the word is a compound word.
      - **`compound_entities`**: Lists the individual components of a compound word (e.g., "Abendbrot" → ["Abend", "Brot"]).
      - **`genus`**: Indicates the grammatical gender of the word (`masculine`, `feminine`, or `neuter`).
      - **`case_X_singular` / `case_X_plural`**: Specifies the word's grammatical cases in singular and plural forms, including the associated articles.
      - **`example_sentences`**: Example sentences demonstrating the word's use in context.
      - **`topics`**: Categories or themes to which the word belongs (e.g., "Essen und Trinken").

      Instructions
      1. Analyze and Correct:
      - Review the dataset for missing or incomplete fields related to the meaning or grammar properties of the German words.
      - Identify and correct inaccuracies in the existing data, ensuring it aligns with standard German grammar and vocabulary rules.

      2. Correct and Suggest Missing Values:
      - Suggest accurate and context-appropriate values for missing information about each German word.
      - For grammar properties, include relevant details such as part of speech, gender (where applicable), plural forms, case usage, and verb conjugations.

      3.  Adhere to JSON Schema
      - Ensure the output JSON strictly adheres to the provided JSON schema. Do not add or remove fields that are not specified by the schema.
      - Validate the structure and formatting of the JSON output to ensure compliance with the schema requirements.

      4. Language Requirements:
      - All suggested and corrected values must be in the German language and adhere to German grammar rules.
      - Use vocabulary and explanations that are suitable for teaching children aged 6 to 10.

      5. Consistency and Accuracy:
      - Ensure all grammar properties and meanings are consistent with the word's usage in German.
      - Verify that the enriched dataset reflects standard German linguistic rules and is accurate for educational purposes.
      6. Output Formatting:
      - Your output must be a JSON value formatted to match the provided schema exactly.
      - Do not include any extraneous information or commentary outside the JSON structure.
      - Your response should contain only the corrected and enriched dataset in the specified JSON format.
    PROMPT

    KEYWORDS_PROMPT = <<~PROMPT
      Stelle dir vor, du bist eine Grundschullehrerin und sollst Schülern auf einfache Weise erklären, was ein bestimmter Begriff bedeutet. Ähnlich dem Spiel Tabu. Gib mir dazu bitte 3–5 kurze, kinderfreundliche Wörter, die den Begriff beschreiben.

      Wichtig:

      - Verwende keine Wörter, die der ursprüngliche Begriff bereits enthält, oder die eine offensichtliche Abwandlung davon sind.
      - Nutze stattdessen einfache, beschreibende Wörter, damit Kinder den Begriff verstehen können.
      - Gib nur einzelne Wörter, keine Wortgruppen oder Sätze.

      Beispiele:

      - Schwan: groß, Tier, weiß
      - Elefant: grau, groß, Rüssel, Tier

      Deine Aufgabe: Wenn ich dir jetzt einen neuen Begriff nenne, antworte bitte ausschließlich mit 3–5 passenden Wörtern, die Grundschulkinder verstehen können, ohne Teile oder Ableitungen des Begriffs selbst zu verwenden. Nenne nur die Wörter selbst als Komma separate Liste und nichts weiter.

      Begriff: {word}

      Bitte wähle nur Wörter aus der folgenden Liste: {valid_keywords}

      Bitte antworte als JSON Objekt. Beispiel:

      ```json
      {{ "keywords": ["Erstes Wort", "Zweites Wort"] }}
      ```
    PROMPT

    attr_reader :word, :word_llm_invocation

    def initialize(word:)
      @word = word
      @llm_invoke_all_properties ||= Invoke.new(
        include_format_instructions: false,
        response_model: all_properties_response_model,
        prompt_variables: {
          input_dataset: all_properties_response_model.from_word(word).to_json
        },
        prompt: ALL_PROPERTIES_PROMPT
      )
    end

    def call
      return if pending_llm_response?

      initialize_word_llm_invocation

      response = all_properties_llm_response
      create_enriched_attributes(response, all_properties_response_model)

      response = keywords_llm_response
      create_enriched_attributes(response, keywords_response_model)

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

    def full_prompt
      @llm_invoke_all_properties.full_prompt
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
      @llm_invoke_all_properties.call
    end

    def keywords_llm_response
      Invoke.new(
        include_format_instructions: false,
        response_model: keywords_response_model,
        prompt_variables: {
          word: word.name,
          valid_keywords: Word.where(id: Keyword.distinct.pluck(:keyword_id)).pluck(:name).join(", ")
        },
        prompt: KEYWORDS_PROMPT
      ).call
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
