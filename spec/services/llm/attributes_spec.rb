# frozen_string_literal: true

RSpec.describe Llm::Attributes do
  describe ".response_model" do
    it "returns the correct schema for Noun" do
      expect(described_class.response_model("Noun")).to eq(Llm::Schema::Noun)
    end

    it "returns the correct schema for Verb" do
      expect(described_class.response_model("Verb")).to eq(Llm::Schema::Verb)
    end

    it "returns the correct schema for Adjective" do
      expect(described_class.response_model("Adjective")).to eq(Llm::Schema::Adjective)
    end

    it "returns the correct schema for FunctionWord" do
      expect(described_class.response_model("FunctionWord")).to eq(Llm::Schema::FunctionWord)
    end

    it "raises an error for unsupported word types" do
      expect { described_class.response_model("InvalidType") }.to raise_error(
        Llm::Attributes::UnsupportedWordType,
        "Word type 'InvalidType' is not supported for LLM enrichment"
      )
    end
  end

  describe ".filter" do
    let!(:noun) { create(:noun, name: "Spielen") }
    let!(:verb) { create(:noun, name: "spielen") }

    it "returns matches irrelevant of capitalization" do
      expect(
        described_class.filter(
          response_model: Llm::Schema::Keywords,
          attribute_name: "keywords",
          value: ["Spielen"]
        )
      ).to match_array [noun.id.to_s, verb.id.to_s]
    end

    context "with case sensitive search" do
      before do
        allow(Rails.application.config).to receive(:reviews_keywords_search_case_insensitive).and_return(false)
      end

      it "returns only exact matches" do
        expect(
          described_class.filter(
            response_model: Llm::Schema::Keywords,
            attribute_name: "keywords",
            value: ["Spielen"]
          )
        ).to match_array [noun.id.to_s]
      end
    end
  end
end
