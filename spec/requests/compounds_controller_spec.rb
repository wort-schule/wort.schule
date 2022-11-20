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

    it "returns words and compounds" do
      get compounds_path(format: :json)

      expect(JSON.parse(response.body, symbolize_names: true)).to match_array [
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
      ]
    end
  end
end
