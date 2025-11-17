# frozen_string_literal: true

RSpec.describe Llm::Invoke do
  let(:word) { create(:noun, name: "Katze") }
  let(:llm_service) { create(:llm_service, model: model) }
  let(:response_model) { Llm::Schema::Keywords }
  let(:prompt) { "Test prompt" }
  let(:prompt_variables) { {word: "Test"} }

  subject do
    described_class.new(
      prompt: prompt,
      prompt_variables: prompt_variables,
      response_model: response_model,
      model: model
    )
  end

  describe "#gpt5_model?" do
    context "with GPT-4 models" do
      let(:model) { "gpt-4" }

      it "returns false for gpt-4" do
        expect(subject.send(:gpt5_model?)).to be false
      end
    end

    context "with GPT-4.1 models" do
      let(:model) { "gpt-4.1" }

      it "returns false for gpt-4.1" do
        expect(subject.send(:gpt5_model?)).to be false
      end
    end

    context "with GPT-5 models" do
      let(:model) { "gpt-5" }

      it "returns true for gpt-5" do
        expect(subject.send(:gpt5_model?)).to be true
      end
    end

    context "with GPT-5-mini models" do
      let(:model) { "gpt-5-mini" }

      it "returns true for gpt-5-mini" do
        expect(subject.send(:gpt5_model?)).to be true
      end
    end

    context "with GPT-5-nano models" do
      let(:model) { "gpt-5-nano" }

      it "returns true for gpt-5-nano" do
        expect(subject.send(:gpt5_model?)).to be true
      end
    end

    context "with case variations" do
      let(:model) { "GPT-5-MINI" }

      it "returns true for GPT-5-MINI (uppercase)" do
        expect(subject.send(:gpt5_model?)).to be true
      end
    end
  end

  describe "#client_options" do
    context "with GPT-4 models" do
      let(:model) { "gpt-4" }

      it "includes temperature parameter" do
        options = subject.send(:client_options)
        expect(options).to include(temperature: 0.0)
        expect(options).to include(chat_model: "gpt-4")
      end
    end

    context "with GPT-5 models" do
      let(:model) { "gpt-5-mini" }

      it "excludes temperature parameter" do
        options = subject.send(:client_options)
        expect(options).not_to have_key(:temperature)
        expect(options).to include(chat_model: "gpt-5-mini")
      end
    end

    context "with GPT-5-nano models" do
      let(:model) { "gpt-5-nano" }

      it "excludes temperature parameter" do
        options = subject.send(:client_options)
        expect(options).not_to have_key(:temperature)
        expect(options).to include(chat_model: "gpt-5-nano")
      end
    end
  end
end
