# frozen_string_literal: true

RSpec.describe "word filter" do
  describe "filtering words" do
    before do
      words.each do |word|
        create :noun, name: word
      end

      visit search_path
    end

    let(:words) do
      %w[
        Abfall
        Abend
        Bach
      ]
    end

    it "filters words", js: true do
      words.each do |word|
        expect(page).to have_content word
      end

      fill_in t("filter.wordstarts"), with: "a"

      expect(page).to have_content "Abfall"
      expect(page).to have_content "Abend"
      expect(page).not_to have_content "Bach"

      click_on t("filter.reset")

      words.each do |word|
        expect(page).to have_content word
      end
    end
  end

  describe "filter specific word types" do
    let!(:noun) { create :noun, name: "Abend" }
    let!(:verb) { create :verb, name: "abbauen" }
    let!(:adjective) { create :adjective, name: "abstrakt" }

    before do
      visit search_path
      fill_in t("filter.wordstarts"), with: "ab"
    end

    it "filters a specific word type", js: true do
      expect(page).to have_content "Abend"
      expect(page).to have_content "abbauen"
      expect(page).to have_content "abstrakt"

      choose t("activerecord.models.noun.one")
      expect(page).to have_content "Abend"
      expect(page).not_to have_content "abbauen"
      expect(page).not_to have_content "abstrakt"

      choose t("filter.all")
      expect(page).to have_content "Abend"
      expect(page).to have_content "abbauen"
      expect(page).to have_content "abstrakt"
    end
  end
end
