# frozen_string_literal: true

RSpec.describe CompoundsController, type: :request do
  let(:admin) { create :admin }

  before do
    sign_in admin
  end

  describe "#index" do
    let!(:noun) { create :noun, name: "Bach" }
    let!(:noun_with_meaning) { create :noun, name: "Haus", meaning: "Gebäude" }
    let!(:compound_postconfix) { create :compound_postconfix, name: "-thek" }
    let!(:function_word) { create :function_word, name: "die" }

    context "without search query" do
      it "returns a limited set of words and compounds" do
        get compounds_path(format: :json)

        # Should return limited results (10 of each type)
        result = JSON.parse(response.body, symbolize_names: true)
        expect(result).to include(
          {
            text: "Bach",
            value: "Word:#{noun.id}"
          },
          {
            text: "Haus [Gebäude]",
            value: "Word:#{noun_with_meaning.id}"
          },
          {
            text: "-thek [Postkonfix]",
            value: "CompoundPostconfix:#{compound_postconfix.id}"
          },
          {
            text: "die",
            value: "Word:#{function_word.id}"
          }
        )
      end
    end

    context "with search query" do
      it "filters results by query" do
        get compounds_path(format: :json, q: "Haus")

        result = JSON.parse(response.body, symbolize_names: true)
        expect(result).to include(
          {
            text: "Haus [Gebäude]",
            value: "Word:#{noun_with_meaning.id}"
          }
        )
        expect(result).not_to include(
          {
            text: "Bach",
            value: "Word:#{noun.id}"
          }
        )
      end
    end
  end
end
