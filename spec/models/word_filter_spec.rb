# frozen_string_literal: true

RSpec.describe "WordFilter keyword filtering" do
  describe ".filter_keywords" do
    let!(:abfall) { create(:noun, name: "Abfall") }
    let!(:abend) { create(:noun, name: "Abend") }
    let!(:bach) { create(:noun, name: "Bach") }

    before do
      # Set up Abfall to have Bach as a keyword
      abfall.keywords << bach
      abfall.save!
    end

    it "filters words by keyword using the filter_keywords scope" do
      # Test the scope directly
      result = Word.filter_keywords(keywords: [bach.id])

      expect(result).to include(abfall)
      expect(result).not_to include(abend)
      expect(result).not_to include(bach)
    end

    it "filters words with multiple keywords using OR conjunction" do
      # Add another word with a different keyword
      katze = create(:noun, name: "Katze")
      abend.keywords << katze
      abend.save!

      result = Word.filter_keywords(keywords: [bach.id, katze.id], conjunction: "or")

      expect(result).to include(abfall) # has Bach as keyword
      expect(result).to include(abend)  # has Katze as keyword
      expect(result).not_to include(bach)
      expect(result).not_to include(katze)
    end

    it "filters words with multiple keywords using AND conjunction" do
      # Add another keyword to Abfall
      katze = create(:noun, name: "Katze")
      abfall.keywords << katze
      abfall.save!

      # Abend gets only Katze
      abend.keywords << katze
      abend.save!

      result = Word.filter_keywords(keywords: [bach.id, katze.id], conjunction: "and")

      expect(result).to include(abfall) # has both Bach and Katze
      expect(result).not_to include(abend) # has only Katze
    end
  end
end