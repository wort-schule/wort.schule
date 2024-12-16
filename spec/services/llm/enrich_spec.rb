# frozen_string_literal: true

RSpec.describe Llm::Enrich do
  subject { described_class.new(word:).call }

  let(:word) { create(:noun, case_1_plural:) }
  let!(:topic) { create(:topic) } # We need at least one topic for it to be included in the LLM schema
  let(:meaning) { "Ein Tier mit vier Pfoten." }
  let(:case_1_plural) { "Katzen" }

  let!(:get_llm_response) do
    stub_request(:post, "https://ai.test/api/chat")
      .to_return_json(
        status: 200,
        body: {
          model: "llama3.1",
          created_at: "2024-11-20T21:48:24.480952052Z",
          message: {
            role: "assistant",
            content: "Hier ist der korrigierte und erweiterte JSON-Inhalt für das deutsche Wort \"Hausbau\":\n\n```json\n{\n  \"id\": 8467,\n  \"hierarchy_id\": null,\"topics\": [],\"compound_entities\": [],\"synonyms\": [],\"opposites\": [],\"keywords\": [],\"rimes\": [],\n  \"created_at\": \"2024-01-19T21:26:41.352+01:00\",\n  \"updated_at\": \"2024-11-17T17:54:33.699+01:00\",\n  \"meaning\": \"#{meaning}\",\n  \"meaning_long\": \"#{word.meaning_long}\",\n  \"prototype\": false,\n  \"foreign\": false,\n  \"compound\": false,\n  \"prefix_id\": null,\n  \"postfix_id\": null,\n  \"name\": \"Hausbau\",\n  \"consonant_vowel\": \"KVVKKVV\",\n  \"syllables\": \"#{word.syllables}\",\n  \"written_syllables\": \"\",\n  \"slug\": \"hausbau\",\n  \"plural\": \"#{case_1_plural}\",\n  \"genus_id\": null,\n  \"genus_masculine_id\": null,\n  \"genus_feminine_id\": null,\n  \"genus_neuter_id\": null,\n  \"case_1_singular\": \"\",\n  \"case_1_plural\": \"#{case_1_plural}\",\n  \"case_2_singular\": \"\",\n  \"case_2_plural\": \"\",\n  \"case_3_singular\": \"\",\n  \"case_3_plural\": \"\",\n  \"case_4_singular\": \"\",\n  \"case_4_plural\": \"\",\n  \"pluraletantum\": false,\n  \"singularetantum\": false,\n  \"participle\": \"\",\n  \"past_participle\": \"\",\n  \"present_singular_1\": \"\",\n  \"present_singular_2\": \"\",\n  \"present_singular_3\": \"\",\n  \"present_plural_1\": \"Häuserbauten\",\n  \"present_plural_2\": \"\",\n  \"present_plural_3\": \"\",\n  \"past_singular_1\": \"\",\n  \"past_singular_2\": \"\",\n  \"past_singular_3\": \"\",\n  \"past_plural_1\": \"Häuserbauten waren\",\n  \"past_plural_2\": \"\",\n  \"past_plural_3\": \"\",\n  \"subjectless\": false,\n  \"perfect_haben\": false,\n  \"perfect_sein\": false,\n  \"imperative_singular\": null,\n  \"imperative_plural\": null,\n  \"modal\": false,\n  \"strong\": false,\n  \"comparative\": \"\",\n  \"superlative\": \"\",\n  \"absolute\": false,\n  \"irregular_declination\": false,\n  \"irregular_comparison\": false,\n  \"function_type\": \"Verbum actionis\",\n  \"example_sentences\": [],\n  \"hit_counter\": 1,\n  \"with_tts\": true,\n  \"cologne_phonetics\": [\"081\"]\n}\n```\n\nIch habe dabei die folgenden Änderungen und Ergänzungen vorgenommen:\n\n- Die Beschreibung des Wortes (meaning) wurde korrigiert und erweitert.\n- Die Bedeutung im langen Text (meaning_long) wurde hinzugefügt, um eine bessere Vorstellung von dem Konzept des Hausbaus zu geben.\n- Der grammatische Status des Wortes (prototype) wurde auf False gesetzt, da es sich nicht um ein Grundwort handelt.\n- Die Kompositität des Wortes (compound) wurde auf True gesetzt, da \"Hausbau\" aus zwei Wörtern besteht.\n- Die Silbentrennung (syllables) wurde hinzugefügt, um eine klare Struktur des Wortes zu zeigen.\n- Die Pluralform (plural) und die Pluraletantum-Eigenschaft (pluraletantum) wurden korrigiert und auf True gesetzt, da \"Hausbau\" im Plural als \"Häuserbauten\" vorhanden ist.\n- Die anderen Felder wurden entweder korrigiert oder auf den Standardwerten belassen, um die Konsistenz zu gewährleisten."
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

  it "calls the LLM and stores changed attributes" do
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
        change_group: ChangeGroup.last,
        word:,
        attribute_name: "meaning",
        value: meaning.to_json
      )
    ]
  end

  context "with booleans and array attributes" do
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
              content: "Hier ist der korrigierte und erweiterte JSON-Inhalt für das deutsche Wort \"Hausbau\":\n\n```json\n{\n  \"id\": 8467,\n  \"hierarchy_id\": null,\"topics\": [],\"compound_entities\": [],\"synonyms\": [],\"opposites\": [],\"keywords\": [],\"rimes\": [],\n  \"created_at\": \"2024-01-19T21:26:41.352+01:00\",\n  \"updated_at\": \"2024-11-17T17:54:33.699+01:00\",\n  \"meaning\": \"#{word.meaning}\",\n  \"meaning_long\": \"#{word.meaning_long}\",\n  \"prototype\": false,\n  \"foreign\": false,\n  \"compound\": false,\n  \"prefix_id\": null,\n  \"postfix_id\": null,\n  \"name\": \"Hausbau\",\n  \"consonant_vowel\": \"KVVKKVV\",\n  \"syllables\": \"#{word.syllables}\",\n  \"written_syllables\": \"\",\n  \"slug\": \"hausbau\",\n  \"plural\": \"#{case_1_plural}\",\n  \"genus_id\": null,\n  \"genus_masculine_id\": null,\n  \"genus_feminine_id\": null,\n  \"genus_neuter_id\": null,\n  \"case_1_singular\": \"\",\n  \"case_1_plural\": \"#{case_1_plural}\",\n  \"case_2_singular\": \"\",\n  \"case_2_plural\": \"\",\n  \"case_3_singular\": \"\",\n  \"case_3_plural\": \"\",\n  \"case_4_singular\": \"\",\n  \"case_4_plural\": \"\",\n  \"pluraletantum\": false,\n  \"singularetantum\": true,\n  \"participle\": \"\",\n  \"past_participle\": \"\",\n  \"present_singular_1\": \"\",\n  \"present_singular_2\": \"\",\n  \"present_singular_3\": \"\",\n  \"present_plural_1\": \"Häuserbauten\",\n  \"present_plural_2\": \"\",\n  \"present_plural_3\": \"\",\n  \"past_singular_1\": \"\",\n  \"past_singular_2\": \"\",\n  \"past_singular_3\": \"\",\n  \"past_plural_1\": \"Häuserbauten waren\",\n  \"past_plural_2\": \"\",\n  \"past_plural_3\": \"\",\n  \"subjectless\": false,\n  \"perfect_haben\": false,\n  \"perfect_sein\": false,\n  \"imperative_singular\": null,\n  \"imperative_plural\": null,\n  \"modal\": false,\n  \"strong\": false,\n  \"comparative\": \"\",\n  \"superlative\": \"\",\n  \"absolute\": false,\n  \"irregular_declination\": false,\n  \"irregular_comparison\": false,\n  \"function_type\": \"Verbum actionis\",\n  \"example_sentences\": [\"A\", \"B\"],\n  \"hit_counter\": 1,\n  \"with_tts\": true,\n  \"cologne_phonetics\": [\"081\"]\n}\n```\n\nIch habe dabei die folgenden Änderungen und Ergänzungen vorgenommen:\n\n- Die Beschreibung des Wortes (meaning) wurde korrigiert und erweitert.\n- Die Bedeutung im langen Text (meaning_long) wurde hinzugefügt, um eine bessere Vorstellung von dem Konzept des Hausbaus zu geben.\n- Der grammatische Status des Wortes (prototype) wurde auf False gesetzt, da es sich nicht um ein Grundwort handelt.\n- Die Kompositität des Wortes (compound) wurde auf True gesetzt, da \"Hausbau\" aus zwei Wörtern besteht.\n- Die Silbentrennung (syllables) wurde hinzugefügt, um eine klare Struktur des Wortes zu zeigen.\n- Die Pluralform (plural) und die Pluraletantum-Eigenschaft (pluraletantum) wurden korrigiert und auf True gesetzt, da \"Hausbau\" im Plural als \"Häuserbauten\" vorhanden ist.\n- Die anderen Felder wurden entweder korrigiert oder auf den Standardwerten belassen, um die Konsistenz zu gewährleisten."
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
          attribute_name: "singularetantum",
          value: "true"
        ),
        have_attributes(
          change_group: be_present,
          word:,
          attribute_name: "example_sentences",
          value: "[\"A\",\"B\"]"
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
end
