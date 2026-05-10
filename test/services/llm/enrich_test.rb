# frozen_string_literal: true

require "test_helper"

class Llm::EnrichTest < ActiveSupport::TestCase
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

  setup do
    @case_1_plural = "Katzen"
    @existing_keyword = create(:noun, name: "Tier")
    @topic = create(:topic)
    @llm_service = create(:llm_service)

    LlmPrompt.create!(identifier: "all_properties", content: ALL_PROPERTIES_PROMPT)
    LlmPrompt.create!(identifier: "keywords", content: KEYWORDS_PROMPT)
  end

  def stub_llm_response(content)
    stub_request(:post, "https://ai.test/api/chat")
      .to_return_json(
        status: 200,
        body: {
          model: "llama3.1",
          created_at: "2024-11-20T21:48:24.480952052Z",
          message: {role: "assistant", content: content},
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

  test "calls the LLM and stores changed attributes" do
    word = create(:noun, case_1_plural: @case_1_plural, name: "Katze")
    meaning = "Ein Tier mit vier Pfoten."
    keywords = ["Bach", "Tier"]
    content = "Hier ist der korrigierte und erweiterte JSON-Inhalt für das deutsche Wort \"Hausbau\":\n\n```json\n{\n  \"id\": 8467,\n  \"hierarchy_id\": null,\"topics\": [],\"compound_entities\": [],\"synonyms\": [],\"opposites\": [],\"keywords\": #{keywords.inspect},\"rimes\": [],\n  \"created_at\": \"2024-01-19T21:26:41.352+01:00\",\n  \"updated_at\": \"2024-11-17T17:54:33.699+01:00\",\n  \"meaning\": \"#{meaning}\",\n  \"meaning_long\": \"#{word.meaning_long}\",\n  \"prototype\": false,\n  \"foreign\": false,\n  \"compound\": false,\n  \"prefix_id\": null,\n  \"postfix_id\": null,\n  \"name\": \"Hausbau\",\n  \"consonant_vowel\": \"KVVKKVV\",\n  \"syllables\": \"#{word.syllables}\",\n  \"written_syllables\": \"\",\n  \"slug\": \"hausbau\",\n  \"plural\": \"#{@case_1_plural}\",\n  \"genus_id\": null,\n  \"genus_masculine_id\": null,\n  \"genus_feminine_id\": null,\n  \"genus_neuter_id\": null,\n  \"case_1_singular\": \"\",\n  \"case_1_plural\": \"#{@case_1_plural}\",\n  \"case_2_singular\": \"\",\n  \"case_2_plural\": \"\",\n  \"case_3_singular\": \"\",\n  \"case_3_plural\": \"\",\n  \"case_4_singular\": \"\",\n  \"case_4_plural\": \"\",\n  \"pluraletantum\": false,\n  \"singularetantum\": false,\n  \"participle\": \"\",\n  \"past_participle\": \"\",\n  \"present_singular_1\": \"\",\n  \"present_singular_2\": \"\",\n  \"present_singular_3\": \"\",\n  \"present_plural_1\": \"Häuserbauten\",\n  \"present_plural_2\": \"\",\n  \"present_plural_3\": \"\",\n  \"past_singular_1\": \"\",\n  \"past_singular_2\": \"\",\n  \"past_singular_3\": \"\",\n  \"past_plural_1\": \"Häuserbauten waren\",\n  \"past_plural_2\": \"\",\n  \"past_plural_3\": \"\",\n  \"subjectless\": false,\n  \"perfect_haben\": false,\n  \"perfect_sein\": false,\n  \"imperative_singular\": null,\n  \"imperative_plural\": null,\n  \"modal\": false,\n  \"strong\": false,\n  \"comparative\": \"\",\n  \"superlative\": \"\",\n  \"absolute\": false,\n  \"irregular_declination\": false,\n  \"irregular_comparison\": false,\n  \"function_type\": \"Verbum actionis\",\n  \"example_sentences\": [],\n  \"hit_counter\": 1,\n  \"with_tts\": true,\n  \"cologne_phonetics\": [\"081\"]\n}\n```"
    stub_llm_response(content)

    assert_difference -> { WordLlmInvocation.count }, 1 do
      assert_difference -> { WordAttributeEdit.count }, 2 do
        assert_difference -> { ChangeGroup.count }, 2 do
          Llm::Enrich.new(word: word).call
        end
      end
    end

    invocation = WordLlmInvocation.last
    assert_equal "Noun##{word.id}", invocation.key
    assert_equal "enrichment", invocation.invocation_type
    assert_equal "completed", invocation.state

    assert_equal "waiting_for_review", ChangeGroup.last.state

    edits = WordAttributeEdit.all.to_a
    assert_equal 2, edits.size
    meaning_edit = edits.find { |e| e.attribute_name == "meaning" }
    keywords_edit = edits.find { |e| e.attribute_name == "keywords" }
    refute_nil meaning_edit
    refute_nil keywords_edit
    assert_equal meaning.to_json, meaning_edit.value
    assert_equal word, meaning_edit.word
    assert_equal [@existing_keyword.id.to_s, "Bach"].to_json, keywords_edit.value
  end

  test "with booleans and array attributes stores booleans and arrays" do
    word = create(:noun, case_1_plural: @case_1_plural, singularetantum: false, name: "Katze")
    keywords = ["Bach", "Tier"]
    content = "Hier ist der korrigierte und erweiterte JSON-Inhalt für das deutsche Wort \"Hausbau\":\n\n```json\n{\n  \"id\": 8467,\n  \"hierarchy_id\": null,\"topics\": [],\"compound_entities\": [],\"synonyms\": [],\"opposites\": [],\"keywords\": #{keywords.inspect},\"rimes\": [],\n  \"created_at\": \"2024-01-19T21:26:41.352+01:00\",\n  \"updated_at\": \"2024-11-17T17:54:33.699+01:00\",\n  \"meaning\": \"#{word.meaning}\",\n  \"meaning_long\": \"#{word.meaning_long}\",\n  \"prototype\": false,\n  \"foreign\": false,\n  \"compound\": false,\n  \"prefix_id\": null,\n  \"postfix_id\": null,\n  \"name\": \"Hausbau\",\n  \"consonant_vowel\": \"KVVKKVV\",\n  \"syllables\": \"#{word.syllables}\",\n  \"written_syllables\": \"\",\n  \"slug\": \"hausbau\",\n  \"plural\": \"#{@case_1_plural}\",\n  \"genus_id\": null,\n  \"genus_masculine_id\": null,\n  \"genus_feminine_id\": null,\n  \"genus_neuter_id\": null,\n  \"case_1_singular\": \"\",\n  \"case_1_plural\": \"#{@case_1_plural}\",\n  \"case_2_singular\": \"\",\n  \"case_2_plural\": \"\",\n  \"case_3_singular\": \"\",\n  \"case_3_plural\": \"\",\n  \"case_4_singular\": \"\",\n  \"case_4_plural\": \"\",\n  \"pluraletantum\": false,\n  \"singularetantum\": true,\n  \"participle\": \"\",\n  \"past_participle\": \"\",\n  \"present_singular_1\": \"\",\n  \"present_singular_2\": \"\",\n  \"present_singular_3\": \"\",\n  \"present_plural_1\": \"Häuserbauten\",\n  \"present_plural_2\": \"\",\n  \"present_plural_3\": \"\",\n  \"past_singular_1\": \"\",\n  \"past_singular_2\": \"\",\n  \"past_singular_3\": \"\",\n  \"past_plural_1\": \"Häuserbauten waren\",\n  \"past_plural_2\": \"\",\n  \"past_plural_3\": \"\",\n  \"subjectless\": false,\n  \"perfect_haben\": false,\n  \"perfect_sein\": false,\n  \"imperative_singular\": null,\n  \"imperative_plural\": null,\n  \"modal\": false,\n  \"strong\": false,\n  \"comparative\": \"\",\n  \"superlative\": \"\",\n  \"absolute\": false,\n  \"irregular_declination\": false,\n  \"irregular_comparison\": false,\n  \"function_type\": \"Verbum actionis\",\n  \"example_sentences\": [\"A\", \"B\"],\n  \"hit_counter\": 1,\n  \"with_tts\": true,\n  \"cologne_phonetics\": [\"081\"]\n}\n```"
    stub_llm_response(content)

    assert_difference -> { WordLlmInvocation.count }, 1 do
      assert_difference -> { WordAttributeEdit.count }, 3 do
        assert_difference -> { ChangeGroup.count }, 3 do
          Llm::Enrich.new(word: word).call
        end
      end
    end

    invocation = WordLlmInvocation.last
    assert_equal "Noun##{word.id}", invocation.key
    assert_equal "enrichment", invocation.invocation_type
    assert_equal "completed", invocation.state
    assert_equal "waiting_for_review", ChangeGroup.last.state

    edits = WordAttributeEdit.all.to_a
    sing_edit = edits.find { |e| e.attribute_name == "singularetantum" }
    sentences_edit = edits.find { |e| e.attribute_name == "example_sentences" }
    keywords_edit = edits.find { |e| e.attribute_name == "keywords" }
    refute_nil sing_edit
    refute_nil sentences_edit
    refute_nil keywords_edit
    assert_equal "true", sing_edit.value
    assert_equal '["A","B"]', sentences_edit.value
    assert_equal [@existing_keyword.id.to_s, "Bach"].to_json, keywords_edit.value
  end

  test "with an empty array response does not store a change" do
    word = create(:noun, case_1_plural: @case_1_plural, singularetantum: false)
    stub_llm_response("```json\n{\n  \"id\": 8467,\n  \"topics\": []\n}\n```")

    assert_difference -> { WordLlmInvocation.count }, 1 do
      assert_no_difference -> { WordAttributeEdit.count } do
        assert_no_difference -> { ChangeGroup.count } do
          Llm::Enrich.new(word: word).call
        end
      end
    end

    invocation = WordLlmInvocation.last
    assert_equal "Noun##{word.id}", invocation.key
    assert_equal "enrichment", invocation.invocation_type
    assert_equal "completed", invocation.state
  end

  test "with invalid values in an array response does not store a change" do
    word = create(:noun, case_1_plural: @case_1_plural, singularetantum: false)
    stub_llm_response("```json\n{\n  \"id\": 8467,\n  \"topics\": [\"Invalid\"]\n}\n```")

    assert_equal false, Topic.exists?(name: "Invalid")
    assert_difference -> { WordLlmInvocation.count }, 1 do
      assert_no_difference -> { WordAttributeEdit.count } do
        assert_no_difference -> { ChangeGroup.count } do
          Llm::Enrich.new(word: word).call
        end
      end
    end

    invocation = WordLlmInvocation.last
    assert_equal "Noun##{word.id}", invocation.key
    assert_equal "enrichment", invocation.invocation_type
    assert_equal "completed", invocation.state
  end

  test "with valid and invalid values in an array response stores only valid values as change" do
    word = create(:noun, case_1_plural: @case_1_plural, singularetantum: false)
    create(:topic, name: "Baugewerbe")
    stub_llm_response("```json\n{\n  \"id\": 8467,\n  \"topics\": [\"Invalid\", \"Baugewerbe\"]\n}\n```")

    assert_equal false, Topic.exists?(name: "Invalid")
    assert_equal true, Topic.exists?(name: "Baugewerbe")
    assert_difference -> { WordLlmInvocation.count }, 1 do
      assert_difference -> { WordAttributeEdit.count }, 1 do
        assert_difference -> { ChangeGroup.count }, 1 do
          Llm::Enrich.new(word: word).call
        end
      end
    end

    invocation = WordLlmInvocation.last
    assert_equal "Noun##{word.id}", invocation.key
    assert_equal "enrichment", invocation.invocation_type
    assert_equal "completed", invocation.state
    assert_equal "waiting_for_review", ChangeGroup.last.state

    edits = WordAttributeEdit.all.to_a
    assert_equal 1, edits.size
    edit = edits.first
    assert_equal "topics", edit.attribute_name
    assert_equal '["Baugewerbe"]', edit.value
    assert_equal word, edit.word
  end

  test "with valid and invalid values in array response with valid already existing does not store a change" do
    word = create(:noun, case_1_plural: @case_1_plural, singularetantum: false)
    create(:topic, name: "Baugewerbe")
    stub_llm_response("```json\n{\n  \"id\": 8467,\n  \"topics\": [\"Invalid\", \"Baugewerbe\"]\n}\n```")
    word.topics << create(:topic, name: "Baugewerbe")

    assert_equal false, Topic.exists?(name: "Invalid")
    assert_equal true, Topic.exists?(name: "Baugewerbe")
    assert_difference -> { WordLlmInvocation.count }, 1 do
      assert_no_difference -> { WordAttributeEdit.count } do
        assert_no_difference -> { ChangeGroup.count } do
          Llm::Enrich.new(word: word).call
        end
      end
    end

    invocation = WordLlmInvocation.last
    assert_equal "Noun##{word.id}", invocation.key
    assert_equal "enrichment", invocation.invocation_type
    assert_equal "completed", invocation.state
  end

  test "with same array suggestion as existing does not store a change" do
    word = create(:noun, case_1_plural: @case_1_plural, singularetantum: false)
    stub_llm_response("```json\n{\n  \"id\": 8467,\n  \"topics\": [\"Baugewerbe\"]\n}\n```")
    word.topics << create(:topic, name: "Baugewerbe")

    assert_difference -> { WordLlmInvocation.count }, 1 do
      assert_no_difference -> { WordAttributeEdit.count } do
        assert_no_difference -> { ChangeGroup.count } do
          Llm::Enrich.new(word: word).call
        end
      end
    end

    invocation = WordLlmInvocation.last
    assert_equal "Noun##{word.id}", invocation.key
    assert_equal "enrichment", invocation.invocation_type
    assert_equal "completed", invocation.state
  end

  test "with compound entities stores a change" do
    word = create(:noun, case_1_plural: @case_1_plural, singularetantum: false)
    create(:compound_entity, word: word, part: create(:noun, name: "Haus"))
    create(:compound_entity, word: word, part: create(:noun, name: "Bau"))
    stub_llm_response("```json\n{\n  \"id\": 8467,\n  \"compound_entities\": [\"Haus\", \"Bau\"]\n}\n```")

    assert_difference -> { WordLlmInvocation.count }, 1 do
      assert_difference -> { WordAttributeEdit.count }, 1 do
        assert_difference -> { ChangeGroup.count }, 1 do
          Llm::Enrich.new(word: word).call
        end
      end
    end

    invocation = WordLlmInvocation.last
    assert_equal "Noun##{word.id}", invocation.key
    assert_equal "enrichment", invocation.invocation_type
    assert_equal "completed", invocation.state
    assert_equal "waiting_for_review", ChangeGroup.last.state

    edits = WordAttributeEdit.all.to_a
    assert_equal 1, edits.size
    edit = edits.first
    assert_equal "compound_entities", edit.attribute_name
    assert_equal '["Haus","Bau"]', edit.value
    assert_equal word, edit.word
  end

  test "without an all_properties prompt only calls the LLM with the keyword prompt" do
    word = create(:noun, case_1_plural: @case_1_plural, name: "Katze")
    keywords = ["Bach", "Tier"]
    content = "```json\n{\"keywords\": #{keywords.inspect}}\n```"
    stub_llm_response(content)

    LlmPrompt.destroy_all
    LlmPrompt.create!(identifier: "all_properties", content: "")
    LlmPrompt.create!(identifier: "keywords", content: KEYWORDS_PROMPT)

    assert_difference -> { WordLlmInvocation.count }, 1 do
      assert_difference -> { WordAttributeEdit.count }, 1 do
        assert_difference -> { ChangeGroup.count }, 1 do
          Llm::Enrich.new(word: word).call
        end
      end
    end

    invocation = WordLlmInvocation.last
    assert_equal "Noun##{word.id}", invocation.key
    assert_equal "enrichment", invocation.invocation_type
    assert_equal "completed", invocation.state
    assert_equal "waiting_for_review", ChangeGroup.last.state

    edits = WordAttributeEdit.all.to_a
    assert_equal 1, edits.size
    edit = edits.first
    assert_equal "keywords", edit.attribute_name
    assert_equal [@existing_keyword.id.to_s, "Bach"].to_json, edit.value
    assert_equal word, edit.word
  end

  test "#supported? returns true for FunctionWord" do
    function_word = create(:function_word, name: "ab", function_type: "preposition")
    enrichment = Llm::Enrich.new(word: function_word)
    assert_equal true, enrichment.supported?
  end

  test "#supported? returns true for Noun" do
    noun = create(:noun, name: "Haus")
    enrichment = Llm::Enrich.new(word: noun)
    assert_equal true, enrichment.supported?
  end
end
