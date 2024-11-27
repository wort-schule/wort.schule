# frozen_string_literal: true

require "rails_helper"

RSpec.describe Import::Word do
  subject { described_class.new(name:, topic:, word_type:, word_import_id:).call }

  let(:name) { "Katze" }
  let(:topic) { "Tiere" }
  let(:word_type) { "Noun" }
  let!(:word_import_id) { create(:word_import, name:, topic:, word_type:, state: :new).id }

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
