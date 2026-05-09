# frozen_string_literal: true

RSpec.describe "word filter" do
  describe "filtering words" do
    before do
      words.each do |word|
        Noun.find_or_create_by(name: word) do |w|
          w.slug = word.downcase
        end
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

      within "#advanced_search_fields" do
        click_on t("filter.reset")
      end

      words.each do |word|
        expect(page).to have_content word
      end
    end

    it "filters by keywords only", js: true do
      first_word = Word.find_by(name: "Abfall")
      second_word = Word.find_by(name: "Bach")
      first_word.keywords << second_word
      first_word.save!

      visit search_path
      click_on t("filter.open")

      # Only filter by keyword without combining with other filters
      expect(page).to have_select("filterrific[filter_keywords][keywords][]", visible: false, wait: 2)

      keyword_select = find("select[name='filterrific[filter_keywords][keywords][]']", visible: false)
      keyword_select.find("option[value='#{second_word.id}']", visible: false).select_option

      find_button(t("filter.apply"), visible: false).trigger("click")

      # Wait for results
      expect(page).to have_css("#words", wait: 2)

      within "#words" do
        # Should only show Abfall which has Bach as keyword
        expect(page).to have_css '[data-name="Abfall"]'
        expect(page).not_to have_css '[data-name="Abend"]'
        expect(page).not_to have_css '[data-name="Bach"]'
      end
    end

    it "filters words and keywords", js: true do
      words.each do |word|
        expect(page).to have_content word
      end

      first_word = Word.find_by(name: "Abfall")
      second_word = Word.find_by(name: "Bach")
      first_word.keywords << second_word
      first_word.save!
      expect(first_word.reload.keywords).to match_array([second_word])

      click_on t("filter.open")

      # First, set the conjunction to "and" to combine filters properly
      select I18n.t("filter.and"), from: "filterrific[filter_keywords][conjunction]"

      # Use filter_wordstarts for exact prefix matching
      fill_in "filterrific[filter_wordstarts]", with: "ab"

      # Wait for Turbo to update the keywords filter with available options
      expect(page).to have_select("filterrific[filter_keywords][keywords][]", visible: false, wait: 2)

      # Drive TomSelect through its UI for coverage, then force the
      # underlying <select>: Turbo can re-render the keyword frame and
      # wipe what TomSelect wrote before the apply fires.
      tomselect_input = find(".ts-control input", match: :first)
      tomselect_input.fill_in with: second_word.name
      within ".ts-dropdown" do
        find(:css, "[data-value=\"#{second_word.id}\"]").click
      end
      force_select_value("filterrific[filter_keywords][keywords][]", second_word.id)

      find_button(t("filter.apply"), visible: false).trigger("click")

      within "#words" do
        expect(page).to have_css '[data-name="Abfall"]'
        expect(page).to have_no_css '[data-name="Abend"]'
        expect(page).to have_no_css '[data-name="Bach"]'
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

      find(:label, text: t("filter.results.word_type", word_type: "Nomen", count: 1)).click

      # Since the radio button triggers auto-submission, we don't need to click Apply
      # Just wait for the filtered results
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

      # The form lives behind a Stimulus `click->reveal#toggle` button
      # inside an auto-re-rendering turbo_frame. The click + reveal +
      # submit sequence races on Cuprite, so flip the targets ourselves
      # and retry the submit if Turbo replaces the form mid-click.
      force_reveal!
      expect(page).to have_select("list_id", visible: true)
      select list.name, from: "list_id"

      with_node_churn_retry do
        force_reveal!
        click_on t("words.show.lists.add")
      end

      # Wait for the Turbo Stream success render before querying list.words —
      # click_on returns as soon as the click is dispatched, not when the
      # POST round-trip lands.
      expect(page).to have_content(t("filter.added_words_to_list", count: 3))
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
  end
end
