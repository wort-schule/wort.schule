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

      click_on t("filter.open")
      fill_in "filterrific[filter_wordstarts]", with: "a"
      find_button(t("filter.apply"), visible: false).trigger("click")

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
      click_on t("filter.open")
      fill_in "filterrific[filter_wordstarts]", with: "ab"
      find_button(t("filter.apply"), visible: false).trigger("click")
    end

    it "filters a specific word type", js: true do
      expect(page).to have_content "Abend"
      expect(page).to have_content "abbauen"
      expect(page).to have_content "abstrakt"

      find(:label, text: t("filter.results.nouns", count: 1)).click
      find_button(t("filter.apply"), visible: false).trigger("click")

      expect(page).not_to have_content "abbauen"
      expect(page).to have_content "Abend"
      expect(page).not_to have_content "abstrakt"

      find(:label, text: t("filter.results.all", count: 3)).click
      expect(page).to have_content "Abend"
      expect(page).to have_content "abbauen"
      expect(page).to have_content "abstrakt"
    end
  end

  describe "add filtered words to list" do
    let!(:noun) { create :noun, name: "Abend" }
    let!(:verb) { create :verb, name: "abbauen" }
    let!(:adjective) { create :adjective, name: "abstrakt" }
    let(:user) { create :guest }
    let!(:list) { create :list, user: user }

    before do
      login_as user
      visit search_path
      click_on t("filter.open")
      fill_in "filterrific[filter_wordstarts]", with: "ab"
      find_button(t("filter.apply"), visible: false).trigger("click")
    end

    it "filters a specific word type", js: true do
      expect(list.words).to be_empty

      expect(page).to have_content "Abend"
      expect(page).to have_content "abbauen"
      expect(page).to have_content "abstrakt"

      click_on t("filter.add_words_to_list")
      click_on t("words.show.lists.add")

      expect(list.words).to match_array [noun, verb, adjective]
    end
  end

  describe "by cologne phonetics" do
    let!(:noun) { create :noun, name: "Fahrrad" }

    it "shows all words on initial load", js: true do
      visit search_path
      expect(page).to have_content "Fahrrad" # 372
    end

    it "removes words phonetically", js: true do
      visit search_path("filterrific[filter_home]": "Hau") # 0
      expect(page).not_to have_content "Fahrrad"
    end

    it "finds exact phonetic match", js: true do
      visit search_path("filterrific[filter_home]": "Vahrad") # 372
      expect(page).to have_content "Fahrrad"
    end

    it "finds partial phonetic match", js: true do
      visit search_path("filterrific[filter_home]": "Var") # 37
      expect(page).to have_content "Fahrrad"
    end
  end
end
