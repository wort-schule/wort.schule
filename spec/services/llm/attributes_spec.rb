# frozen_string_literal: true

RSpec.describe Llm::Attributes do
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
