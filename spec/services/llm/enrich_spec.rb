# frozen_string_literal: true

RSpec.describe Llm::Enrich do
  subject { described_class.new(word:).call }

  let(:word) { create(:noun, case_1_plural:, name: "Katze") }
  let!(:existing_keyword) { create(:noun, name: "Tier") }
  let!(:topic) { create(:topic) } # We need at least one topic for it to be included in the LLM schema
  let(:meaning) { "Ein Tier mit vier Pfoten." }
  let(:keywords) { ["Bach", "Tier"] }
  let(:case_1_plural) { "Katzen" }
  let!(:llm_service) { create(:llm_service) }

  let(:all_properties_prompt) do
    <<~PROMPT
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
  end

  let(:keywords_prompt) do
    <<~PROMPT
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
  end

  let!(:get_llm_response) do
    stub_request(:post, "https://ai.test/api/chat")
      .to_return_json(
        status: 200,
        body: {
          model: "llama3.1",
          created_at: "2024-11-20T21:48:24.480952052Z",
          message: {
            role: "assistant",
            content: "Hier ist der korrigierte und erweiterte JSON-Inhalt für das deutsche Wort \"Hausbau\":\n\n```json\n{\n  \"id\": 8467,\n  \"hierarchy_id\": null,\"topics\": [],\"compound_entities\": [],\"synonyms\": [],\"opposites\": [],\"keywords\": #{keywords.inspect},\"rimes\": [],\n  \"created_at\": \"2024-01-19T21:26:41.352+01:00\",\n  \"updated_at\": \"2024-11-17T17:54:33.699+01:00\",\n  \"meaning\": \"#{meaning}\",\n  \"meaning_long\": \"#{word.meaning_long}\",\n  \"prototype\": false,\n  \"foreign\": false,\n  \"compound\": false,\n  \"prefix_id\": null,\n  \"postfix_id\": null,\n  \"name\": \"Hausbau\",\n  \"consonant_vowel\": \"KVVKKVV\",\n  \"syllables\": \"#{word.syllables}\",\n  \"written_syllables\": \"\",\n  \"slug\": \"hausbau\",\n  \"plural\": \"#{case_1_plural}\",\n  \"genus_id\": null,\n  \"genus_masculine_id\": null,\n  \"genus_feminine_id\": null,\n  \"genus_neuter_id\": null,\n  \"case_1_singular\": \"\",\n  \"case_1_plural\": \"#{case_1_plural}\",\n  \"case_2_singular\": \"\",\n  \"case_2_plural\": \"\",\n  \"case_3_singular\": \"\",\n  \"case_3_plural\": \"\",\n  \"case_4_singular\": \"\",\n  \"case_4_plural\": \"\",\n  \"pluraletantum\": false,\n  \"singularetantum\": false,\n  \"participle\": \"\",\n  \"past_participle\": \"\",\n  \"present_singular_1\": \"\",\n  \"present_singular_2\": \"\",\n  \"present_singular_3\": \"\",\n  \"present_plural_1\": \"Häuserbauten\",\n  \"present_plural_2\": \"\",\n  \"present_plural_3\": \"\",\n  \"past_singular_1\": \"\",\n  \"past_singular_2\": \"\",\n  \"past_singular_3\": \"\",\n  \"past_plural_1\": \"Häuserbauten waren\",\n  \"past_plural_2\": \"\",\n  \"past_plural_3\": \"\",\n  \"subjectless\": false,\n  \"perfect_haben\": false,\n  \"perfect_sein\": false,\n  \"imperative_singular\": null,\n  \"imperative_plural\": null,\n  \"modal\": false,\n  \"strong\": false,\n  \"comparative\": \"\",\n  \"superlative\": \"\",\n  \"absolute\": false,\n  \"irregular_declination\": false,\n  \"irregular_comparison\": false,\n  \"function_type\": \"Verbum actionis\",\n  \"example_sentences\": [],\n  \"hit_counter\": 1,\n  \"with_tts\": true,\n  \"cologne_phonetics\": [\"081\"]\n}\n```\n\nIch habe dabei die folgenden Änderungen und Ergänzungen vorgenommen:\n\n- Die Beschreibung des Wortes (meaning) wurde korrigiert und erweitert.\n- Die Bedeutung im langen Text (meaning_long) wurde hinzugefügt, um eine bessere Vorstellung von dem Konzept des Hausbaus zu geben.\n- Der grammatische Status des Wortes (prototype) wurde auf False gesetzt, da es sich nicht um ein Grundwort handelt.\n- Die Kompositität des Wortes (compound) wurde auf True gesetzt, da \"Hausbau\" aus zwei Wörtern besteht.\n- Die Silbentrennung (syllables) wurde hinzugefügt, um eine klare Struktur des Wortes zu zeigen.\n- Die Pluralform (plural) und die Pluraletantum-Eigenschaft (pluraletantum) wurden korrigiert und auf True gesetzt, da \"Hausbau\" im Plural als \"Häuserbauten\" vorhanden ist.\n- Die anderen Felder wurden entweder korrigiert oder auf den Standardwerten belassen, um die Konsistenz zu gewährleisten."
          },
          done_reason: "stop",
          done: true,
          total_duration: 347987332616,
          load_duration: 19833664,
          prompt_eval_count: 726,
          prompt_eval_duration: 350627000,
          eval_count: 938,
          eval_duration: 347572054000
        }
      )
  end

  before do
    LlmPrompt.create!(
      identifier: "all_properties",
      content: all_properties_prompt
    )
    LlmPrompt.create!(
      identifier: "keywords",
      content: keywords_prompt
    )
  end

  it "calls the LLM and stores changed attributes" do
    expect { subject }
      .to change(WordLlmInvocation, :count).by(1)
      .and change(WordAttributeEdit, :count).by(2)
      .and change(ChangeGroup, :count).by(2)

    expect(WordLlmInvocation.last).to have_attributes(
      key: "Noun##{word.id}",
      invocation_type: "enrichment",
      state: "completed"
    )

    expect(ChangeGroup.last).to have_attributes(
      state: "waiting_for_review"
    )

    expect(WordAttributeEdit.all).to match_array [
      have_attributes(
        change_group: be_present,
        word:,
        attribute_name: "meaning",
        value: meaning.to_json
      ),
      have_attributes(
        change_group: be_present,
        word:,
        attribute_name: "keywords",
        value: [existing_keyword.id.to_s, "Bach"].to_json
      )
    ]
  end

  context "with booleans and array attributes" do
    let(:word) { create(:noun, case_1_plural:, singularetantum: false, name: "Katze") }
    let!(:get_llm_response) do
      stub_request(:post, "https://ai.test/api/chat")
        .to_return_json(
          status: 200,
          body: {
            model: "llama3.1",
            created_at: "2024-11-20T21:48:24.480952052Z",
            message: {
              role: "assistant",
              content: "Hier ist der korrigierte und erweiterte JSON-Inhalt für das deutsche Wort \"Hausbau\":\n\n```json\n{\n  \"id\": 8467,\n  \"hierarchy_id\": null,\"topics\": [],\"compound_entities\": [],\"synonyms\": [],\"opposites\": [],\"keywords\": #{keywords.inspect},\"rimes\": [],\n  \"created_at\": \"2024-01-19T21:26:41.352+01:00\",\n  \"updated_at\": \"2024-11-17T17:54:33.699+01:00\",\n  \"meaning\": \"#{word.meaning}\",\n  \"meaning_long\": \"#{word.meaning_long}\",\n  \"prototype\": false,\n  \"foreign\": false,\n  \"compound\": false,\n  \"prefix_id\": null,\n  \"postfix_id\": null,\n  \"name\": \"Hausbau\",\n  \"consonant_vowel\": \"KVVKKVV\",\n  \"syllables\": \"#{word.syllables}\",\n  \"written_syllables\": \"\",\n  \"slug\": \"hausbau\",\n  \"plural\": \"#{case_1_plural}\",\n  \"genus_id\": null,\n  \"genus_masculine_id\": null,\n  \"genus_feminine_id\": null,\n  \"genus_neuter_id\": null,\n  \"case_1_singular\": \"\",\n  \"case_1_plural\": \"#{case_1_plural}\",\n  \"case_2_singular\": \"\",\n  \"case_2_plural\": \"\",\n  \"case_3_singular\": \"\",\n  \"case_3_plural\": \"\",\n  \"case_4_singular\": \"\",\n  \"case_4_plural\": \"\",\n  \"pluraletantum\": false,\n  \"singularetantum\": true,\n  \"participle\": \"\",\n  \"past_participle\": \"\",\n  \"present_singular_1\": \"\",\n  \"present_singular_2\": \"\",\n  \"present_singular_3\": \"\",\n  \"present_plural_1\": \"Häuserbauten\",\n  \"present_plural_2\": \"\",\n  \"present_plural_3\": \"\",\n  \"past_singular_1\": \"\",\n  \"past_singular_2\": \"\",\n  \"past_singular_3\": \"\",\n  \"past_plural_1\": \"Häuserbauten waren\",\n  \"past_plural_2\": \"\",\n  \"past_plural_3\": \"\",\n  \"subjectless\": false,\n  \"perfect_haben\": false,\n  \"perfect_sein\": false,\n  \"imperative_singular\": null,\n  \"imperative_plural\": null,\n  \"modal\": false,\n  \"strong\": false,\n  \"comparative\": \"\",\n  \"superlative\": \"\",\n  \"absolute\": false,\n  \"irregular_declination\": false,\n  \"irregular_comparison\": false,\n  \"function_type\": \"Verbum actionis\",\n  \"example_sentences\": [\"A\", \"B\"],\n  \"hit_counter\": 1,\n  \"with_tts\": true,\n  \"cologne_phonetics\": [\"081\"]\n}\n```\n\nIch habe dabei die folgenden Änderungen und Ergänzungen vorgenommen:\n\n- Die Beschreibung des Wortes (meaning) wurde korrigiert und erweitert.\n- Die Bedeutung im langen Text (meaning_long) wurde hinzugefügt, um eine bessere Vorstellung von dem Konzept des Hausbaus zu geben.\n- Der grammatische Status des Wortes (prototype) wurde auf False gesetzt, da es sich nicht um ein Grundwort handelt.\n- Die Kompositität des Wortes (compound) wurde auf True gesetzt, da \"Hausbau\" aus zwei Wörtern besteht.\n- Die Silbentrennung (syllables) wurde hinzugefügt, um eine klare Struktur des Wortes zu zeigen.\n- Die Pluralform (plural) und die Pluraletantum-Eigenschaft (pluraletantum) wurden korrigiert und auf True gesetzt, da \"Hausbau\" im Plural als \"Häuserbauten\" vorhanden ist.\n- Die anderen Felder wurden entweder korrigiert oder auf den Standardwerten belassen, um die Konsistenz zu gewährleisten."
            },
            done_reason: "stop",
            done: true,
            total_duration: 347987332616,
            load_duration: 19833664,
            prompt_eval_count: 726,
            prompt_eval_duration: 350627000,
            eval_count: 938,
            eval_duration: 347572054000
          }
        )
    end

    it "stores booleans and arrays" do
      expect { subject }
        .to change(WordLlmInvocation, :count).by(1)
        .and change(WordAttributeEdit, :count).by(3)
        .and change(ChangeGroup, :count).by(3)

      expect(WordLlmInvocation.last).to have_attributes(
        key: "Noun##{word.id}",
        invocation_type: "enrichment",
        state: "completed"
      )

      expect(ChangeGroup.last).to have_attributes(
        state: "waiting_for_review"
      )

      expect(WordAttributeEdit.all).to match_array [
        have_attributes(
          change_group: be_present,
          word:,
          attribute_name: "singularetantum",
          value: "true"
        ),
        have_attributes(
          change_group: be_present,
          word:,
          attribute_name: "example_sentences",
          value: "[\"A\",\"B\"]"
        ),
        have_attributes(
          change_group: be_present,
          word:,
          attribute_name: "keywords",
          value: [existing_keyword.id.to_s, "Bach"].to_json
        )
      ]
    end
  end

  context "with an empty array response" do
    let(:word) { create(:noun, case_1_plural:, singularetantum: false) }
    let!(:get_llm_response) do
      stub_request(:post, "https://ai.test/api/chat")
        .to_return_json(
          status: 200,
          body: {
            model: "llama3.1",
            created_at: "2024-11-20T21:48:24.480952052Z",
            message: {
              role: "assistant",
              content: "```json\n{\n  \"id\": 8467,\n  \"topics\": []\n}\n```"
            },
            done_reason: "stop",
            done: true,
            total_duration: 347987332616,
            load_duration: 19833664,
            prompt_eval_count: 726,
            prompt_eval_duration: 350627000,
            eval_count: 938,
            eval_duration: 347572054000
          }
        )
    end

    it "does not store a change" do
      expect { subject }
        .to change(WordLlmInvocation, :count).by(1)
        .and not_change(WordAttributeEdit, :count)
        .and not_change(ChangeGroup, :count)

      expect(WordLlmInvocation.last).to have_attributes(
        key: "Noun##{word.id}",
        invocation_type: "enrichment",
        state: "completed"
      )
    end
  end

  context "with invalid values in an array response" do
    let(:word) { create(:noun, case_1_plural:, singularetantum: false) }
    let!(:get_llm_response) do
      stub_request(:post, "https://ai.test/api/chat")
        .to_return_json(
          status: 200,
          body: {
            model: "llama3.1",
            created_at: "2024-11-20T21:48:24.480952052Z",
            message: {
              role: "assistant",
              content: "```json\n{\n  \"id\": 8467,\n  \"topics\": [\"Invalid\"]\n}\n```"
            },
            done_reason: "stop",
            done: true,
            total_duration: 347987332616,
            load_duration: 19833664,
            prompt_eval_count: 726,
            prompt_eval_duration: 350627000,
            eval_count: 938,
            eval_duration: 347572054000
          }
        )
    end

    it "does not store a change" do
      expect(Topic.exists?(name: "Invalid")).to be false
      expect { subject }
        .to change(WordLlmInvocation, :count).by(1)
        .and not_change(WordAttributeEdit, :count)
        .and not_change(ChangeGroup, :count)

      expect(WordLlmInvocation.last).to have_attributes(
        key: "Noun##{word.id}",
        invocation_type: "enrichment",
        state: "completed"
      )
    end
  end

  context "with valid and invalid values in an array response" do
    let(:word) { create(:noun, case_1_plural:, singularetantum: false) }
    let!(:topic) { create(:topic, name: "Baugewerbe") }
    let!(:get_llm_response) do
      stub_request(:post, "https://ai.test/api/chat")
        .to_return_json(
          status: 200,
          body: {
            model: "llama3.1",
            created_at: "2024-11-20T21:48:24.480952052Z",
            message: {
              role: "assistant",
              content: "```json\n{\n  \"id\": 8467,\n  \"topics\": [\"Invalid\", \"Baugewerbe\"]\n}\n```"
            },
            done_reason: "stop",
            done: true,
            total_duration: 347987332616,
            load_duration: 19833664,
            prompt_eval_count: 726,
            prompt_eval_duration: 350627000,
            eval_count: 938,
            eval_duration: 347572054000
          }
        )
    end

    it "stores only valid values as change" do
      expect(Topic.exists?(name: "Invalid")).to be false
      expect(Topic.exists?(name: "Baugewerbe")).to be true
      expect { subject }
        .to change(WordLlmInvocation, :count).by(1)
        .and change(WordAttributeEdit, :count).by(1)
        .and change(ChangeGroup, :count).by(1)

      expect(WordLlmInvocation.last).to have_attributes(
        key: "Noun##{word.id}",
        invocation_type: "enrichment",
        state: "completed"
      )
      expect(ChangeGroup.last).to have_attributes(
        state: "waiting_for_review"
      )

      expect(WordAttributeEdit.all).to match_array [
        have_attributes(
          change_group: be_present,
          word:,
          attribute_name: "topics",
          value: '["Baugewerbe"]'
        )
      ]
    end
  end

  context "with valid and invalid values in an array response with valid already existing" do
    let(:word) { create(:noun, case_1_plural:, singularetantum: false) }
    let!(:topic) { create(:topic, name: "Baugewerbe") }
    let!(:get_llm_response) do
      stub_request(:post, "https://ai.test/api/chat")
        .to_return_json(
          status: 200,
          body: {
            model: "llama3.1",
            created_at: "2024-11-20T21:48:24.480952052Z",
            message: {
              role: "assistant",
              content: "```json\n{\n  \"id\": 8467,\n  \"topics\": [\"Invalid\", \"Baugewerbe\"]\n}\n```"
            },
            done_reason: "stop",
            done: true,
            total_duration: 347987332616,
            load_duration: 19833664,
            prompt_eval_count: 726,
            prompt_eval_duration: 350627000,
            eval_count: 938,
            eval_duration: 347572054000
          }
        )
    end

    before do
      word.topics << create(:topic, name: "Baugewerbe")
    end

    it "does not store a change" do
      expect(Topic.exists?(name: "Invalid")).to be false
      expect(Topic.exists?(name: "Baugewerbe")).to be true
      expect { subject }
        .to change(WordLlmInvocation, :count).by(1)
        .and not_change(WordAttributeEdit, :count)
        .and not_change(ChangeGroup, :count)

      expect(WordLlmInvocation.last).to have_attributes(
        key: "Noun##{word.id}",
        invocation_type: "enrichment",
        state: "completed"
      )
    end
  end

  context "with same array suggestion as existing" do
    let(:word) { create(:noun, case_1_plural:, singularetantum: false) }
    let!(:get_llm_response) do
      stub_request(:post, "https://ai.test/api/chat")
        .to_return_json(
          status: 200,
          body: {
            model: "llama3.1",
            created_at: "2024-11-20T21:48:24.480952052Z",
            message: {
              role: "assistant",
              content: "```json\n{\n  \"id\": 8467,\n  \"topics\": [\"Baugewerbe\"]\n}\n```"
            },
            done_reason: "stop",
            done: true,
            total_duration: 347987332616,
            load_duration: 19833664,
            prompt_eval_count: 726,
            prompt_eval_duration: 350627000,
            eval_count: 938,
            eval_duration: 347572054000
          }
        )
    end

    before do
      word.topics << create(:topic, name: "Baugewerbe")
    end

    it "does not store a change" do
      expect { subject }
        .to change(WordLlmInvocation, :count).by(1)
        .and not_change(WordAttributeEdit, :count)
        .and not_change(ChangeGroup, :count)

      expect(WordLlmInvocation.last).to have_attributes(
        key: "Noun##{word.id}",
        invocation_type: "enrichment",
        state: "completed"
      )
    end
  end

  context "with compound entities" do
    let(:word) { create(:noun, case_1_plural:, singularetantum: false) }
    let!(:haus_compound_entity) { create(:compound_entity, word:, part: create(:noun, name: "Haus")) }
    let!(:bau_compound_entity) { create(:compound_entity, word:, part: create(:noun, name: "Bau")) }
    let!(:get_llm_response) do
      stub_request(:post, "https://ai.test/api/chat")
        .to_return_json(
          status: 200,
          body: {
            model: "llama3.1",
            created_at: "2024-11-20T21:48:24.480952052Z",
            message: {
              role: "assistant",
              content: "```json\n{\n  \"id\": 8467,\n  \"compound_entities\": [\"Haus\", \"Bau\"]\n}\n```"
            },
            done_reason: "stop",
            done: true,
            total_duration: 347987332616,
            load_duration: 19833664,
            prompt_eval_count: 726,
            prompt_eval_duration: 350627000,
            eval_count: 938,
            eval_duration: 347572054000
          }
        )
    end

    it "stores a change" do
      expect { subject }
        .to change(WordLlmInvocation, :count).by(1)
        .and change(WordAttributeEdit, :count).by(1)
        .and change(ChangeGroup, :count).by(1)

      expect(WordLlmInvocation.last).to have_attributes(
        key: "Noun##{word.id}",
        invocation_type: "enrichment",
        state: "completed"
      )
      expect(ChangeGroup.last).to have_attributes(
        state: "waiting_for_review"
      )

      expect(WordAttributeEdit.all).to match_array [
        have_attributes(
          change_group: be_present,
          word:,
          attribute_name: "compound_entities",
          value: '["Haus","Bau"]'
        )
      ]
    end
  end

  context "without a prompt" do
    before do
      LlmPrompt.destroy_all

      LlmPrompt.create!(
        identifier: "all_properties",
        content: ""
      )
      LlmPrompt.create!(
        identifier: "keywords",
        content: keywords_prompt
      )
    end

    it "only calls the LLM with the keyword prompt" do
      expect { subject }
        .to change(WordLlmInvocation, :count).by(1)
        .and change(WordAttributeEdit, :count).by(1)
        .and change(ChangeGroup, :count).by(1)

      expect(WordLlmInvocation.last).to have_attributes(
        key: "Noun##{word.id}",
        invocation_type: "enrichment",
        state: "completed"
      )

      expect(ChangeGroup.last).to have_attributes(
        state: "waiting_for_review"
      )

      expect(WordAttributeEdit.all).to match_array [
        have_attributes(
          change_group: be_present,
          word:,
          attribute_name: "keywords",
          value: [existing_keyword.id.to_s, "Bach"].to_json
        )
      ]
    end
  end

  describe "#supported?" do
    context "with a FunctionWord" do
      let(:function_word) { create(:function_word, name: "ab", function_type: "preposition") }
      let(:enrichment) { described_class.new(word: function_word) }

      it "returns true for FunctionWord" do
        expect(enrichment.supported?).to be true
      end
    end

    context "with a Noun" do
      let(:noun) { create(:noun, name: "Haus") }
      let(:enrichment) { described_class.new(word: noun) }

      it "returns true for Noun" do
        expect(enrichment.supported?).to be true
      end
    end
  end
end
