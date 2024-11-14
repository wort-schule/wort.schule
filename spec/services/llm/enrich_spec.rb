# frozen_string_literal: true

RSpec.describe Llm::Enrich do
  subject { described_class.new(word:).call }

  let(:word) { create(:noun, case_1_plural:) }
  let(:meaning) { "Ein Tier mit vier Pfoten." }
  let(:case_1_plural) { "Katzen" }

  let!(:get_llm_response) do
    stub_request(:post, "https://ai.test/v1/chat/completions")
      .to_return_json(
        status: 200,
        body: {
          "id" => "chatcmpl-294",
          "object" => "chat.completion",
          "created" => 1730551991,
          "model" => "llama3.1",
          "system_fingerprint" => "fp_ollama",
          "choices" => [
            {
              "index" => 0,
              "message" => {
                "role" => "assistant",
                "content" => "",
                "tool_calls" => [
                  {
                    "id" => "call_8l8ogtf5",
                    "type" => "function",
                    "function" => {
                      "name" => "Llm::Schema::Noun",
                      "arguments" => "{\"case_1_plural\":\"#{case_1_plural}\",\"meaning\":\"#{meaning}\"}"
                    }
                  }
                ]
              },
              "finish_reason" => "tool_calls"
            }
          ],
          "usage" => {"prompt_tokens" => 606, "completion_tokens" => 95, "total_tokens" => 701}
        }
      )
  end

  it "calls the LLM and stores changed attributes" do
    expect { subject }
      .to change(WordLlmEnrichment, :count).by(1)
      .and change(WordAttributeEdit, :count).by(1)

    expect(WordLlmEnrichment.last).to have_attributes(
      word:,
      state: "completed"
    )

    expect(WordAttributeEdit.all).to match_array [
      have_attributes(
        word:,
        attribute_name: "meaning",
        value: meaning,
        state: "waiting_for_review"
      )
    ]
  end
end
