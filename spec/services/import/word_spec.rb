# frozen_string_literal: true

require "rails_helper"

RSpec.describe Import::Word do
  subject { described_class.new(name:, topic:, word_type:, word_import_id:).call }

  let(:name) { "Katze" }
  let(:topic) { "Tiere" }
  let(:word_type) { "Noun" }
  let!(:word_import_id) { create(:word_import, name:, topic:, word_type:, state: :new).id }

  before do
    all_properties_prompt = <<~PROMPT
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

    keywords_prompt = <<~PROMPT
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

    LlmPrompt.create!(
      identifier: "all_properties",
      content: all_properties_prompt
    )
    LlmPrompt.create!(
      identifier: "keywords",
      content: keywords_prompt
    )
  end

  context "with an empty database" do
    it "calls the LLM" do
      expect(Llm::CheckBaseForm).to receive(:new).with(word_type:, name:, topic:).and_call_original
      expect_any_instance_of(Llm::CheckBaseForm).to receive(:call).and_return(NewWord.new(word_type:, name:, topic:))

      subject

      expect(WordImport.last).to have_attributes(
        name:,
        topic:,
        word_type:,
        state: "completed"
      )
    end
  end

  context "with the same word" do
    let!(:word) { create(:noun, name:, topics: [build(:topic, name: topic)]) }

    it "enriches the word" do
      expect(Llm::Enrich).to receive(:new).with(word:).and_call_original
      expect_any_instance_of(Llm::Enrich).to receive(:call)

      subject

      expect(WordImport.last).to have_attributes(
        name:,
        topic:,
        word_type:,
        state: "completed"
      )
    end
  end

  context "with a new word" do
    let!(:get_llm_response) do
      stub_request(:post, "https://ai.test/api/chat")
        .to_return_json(
          status: 200,
          body: {
            model: "llama3.1",
            created_at: "2024-11-20T21:48:24.480952052Z",
            message: {
              role: "assistant",
              content: "Hier ist der korrigierte und erweiterte JSON-Inhalt für das deutsche Wort \"Hausbau\":\n\n```json\n{\"base_form\": \"LLM Name\", \"topic\": \"LLM Topic\"}\n```\n\nIch habe dabei die folgenden Änderungen und Ergänzungen vorgenommen:\n\n- Die Beschreibung des Wortes (meaning) wurde korrigiert und erweitert.\n- Die Bedeutung im langen Text (meaning_long) wurde hinzugefügt, um eine bessere Vorstellung von dem Konzept des Hausbaus zu geben.\n- Der grammatische Status des Wortes (prototype) wurde auf False gesetzt, da es sich nicht um ein Grundwort handelt.\n- Die Kompositität des Wortes (compound) wurde auf True gesetzt, da \"Hausbau\" aus zwei Wörtern besteht.\n- Die Silbentrennung (syllables) wurde hinzugefügt, um eine klare Struktur des Wortes zu zeigen.\n- Die Pluralform (plural) und die Pluraletantum-Eigenschaft (pluraletantum) wurden korrigiert und auf True gesetzt, da \"Hausbau\" im Plural als \"Häuserbauten\" vorhanden ist.\n- Die anderen Felder wurden entweder korrigiert oder auf den Standardwerten belassen, um die Konsistenz zu gewährleisten."
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

    it "creates a new word" do
      expect(Llm::CheckBaseForm).to receive(:new).with(word_type:, name:, topic:).and_call_original

      expect { subject }
        .to change(NewWord, :count).by(1)

      expect(NewWord.last).to have_attributes(
        word_type:,
        name:,
        topic:,
        llm_name: "LLM Name",
        llm_topic: "LLM Topic"
      )
    end
  end
end
