# frozen_string_literal: true

require "application_system_test_case"

class FilterTest < ApplicationSystemTestCase
  WORDS = %w[Abfall Abend Bach].freeze

  def seed_words
    WORDS.each do |word|
      Noun.find_or_create_by(name: word) do |w|
        w.slug = word.downcase
      end
    end
  end

  test "filters words" do
    seed_words
    visit search_path

    WORDS.each do |word|
      assert_text word
    end

    click_on t("filter.open")
    fill_in "filterrific[filter_wordstarts]", with: "a"
    find_button(t("filter.apply"), visible: false).trigger("click")

    assert_text "Abfall"
    assert_text "Abend"
    assert_no_text "Bach"

    within "#advanced_search_fields" do
      click_on t("filter.reset")
    end

    WORDS.each do |word|
      assert_text word
    end
  end

  test "filters by keywords only" do
    seed_words
    visit search_path

    first_word = Word.find_by(name: "Abfall")
    second_word = Word.find_by(name: "Bach")
    first_word.keywords << second_word
    first_word.save!

    visit search_path
    click_on t("filter.open")

    assert_selector "select[name='filterrific[filter_keywords][keywords][]']", visible: false, wait: 2

    keyword_select = find("select[name='filterrific[filter_keywords][keywords][]']", visible: false)
    keyword_select.find("option[value='#{second_word.id}']", visible: false).select_option

    find_button(t("filter.apply"), visible: false).trigger("click")

    assert_selector "#words", wait: 2

    within "#words" do
      assert_selector '[data-name="Abfall"]'
      assert_no_selector '[data-name="Abend"]'
      assert_no_selector '[data-name="Bach"]'
    end
  end

  test "filters words and keywords" do
    seed_words
    visit search_path

    WORDS.each do |word|
      assert_text word
    end

    first_word = Word.find_by(name: "Abfall")
    second_word = Word.find_by(name: "Bach")
    first_word.keywords << second_word
    first_word.save!
    assert_equal [second_word], first_word.reload.keywords.to_a

    click_on t("filter.open")

    select I18n.t("filter.and"), from: "filterrific[filter_keywords][conjunction]"

    fill_in "filterrific[filter_wordstarts]", with: "ab"

    assert_selector "select[name='filterrific[filter_keywords][keywords][]']", visible: false, wait: 2

    tomselect_input = find(".ts-control input", match: :first)
    tomselect_input.fill_in with: second_word.name
    within ".ts-dropdown" do
      find(:css, "[data-value=\"#{second_word.id}\"]").click
    end
    force_select_value("filterrific[filter_keywords][keywords][]", second_word.id)

    find_button(t("filter.apply"), visible: false).trigger("click")

    within "#words" do
      assert_selector '[data-name="Abfall"]'
      assert_no_selector '[data-name="Abend"]'
      assert_no_selector '[data-name="Bach"]'
    end
  end

  test "filters a specific word type" do
    create(:noun, name: "Abend")
    create(:verb, name: "abbauen")
    create(:adjective, name: "abstrakt")

    visit search_path
    click_on t("filter.open")
    fill_in "filterrific[filter_wordstarts]", with: "ab"
    find_button(t("filter.apply"), visible: false).trigger("click")

    assert_text "Abend"
    assert_text "abbauen"
    assert_text "abstrakt"

    find(:label, text: t("filter.results.word_type", word_type: "Nomen", count: 1)).click

    assert_no_text "abbauen"
    assert_text "Abend"
    assert_no_text "abstrakt"

    find(:label, text: t("filter.results.all", count: 3)).click
    assert_text "Abend"
    assert_text "abbauen"
    assert_text "abstrakt"
  end

  test "adds filtered words to a list" do
    noun = create(:noun, name: "Abend")
    verb = create(:verb, name: "abbauen")
    adjective = create(:adjective, name: "abstrakt")
    user = create(:guest)
    list = create(:list, user: user)

    login_as user
    visit search_path
    click_on t("filter.open")
    fill_in "filterrific[filter_wordstarts]", with: "ab"
    find_button(t("filter.apply"), visible: false).trigger("click")

    assert_empty list.words

    assert_text "Abend"
    assert_text "abbauen"
    assert_text "abstrakt"

    force_reveal!
    assert_selector "select#list_id", visible: true

    # The add-to-list form lives inside a turbo_frame_tag (:add_words_to_list)
    # that the filter form's submit may re-render mid-test. Picking the option
    # via Capybara, then clicking the button as two separate actions, races
    # that re-render: by the time we click, the <select> we set may have been
    # replaced by an empty one, the form submits with no list_id, the server
    # 404s, and we see the empty form instead of the success flash.
    # Force the value via JS and assert the *outcome* inside a retry loop so
    # a missed click is caught and the click is re-issued.
    expected_flash = t("filter.added_words_to_list", count: 3)
    attempts = 0
    loop do
      force_reveal!
      force_select_value("list_id", list.id.to_s)
      click_on t("words.show.lists.add")
      break if page.has_text?(expected_flash, wait: 5)
      attempts += 1
      raise "add-to-list flash never appeared after 3 attempts" if attempts >= 3
    end

    assert_text expected_flash
    assert_equal [noun, verb, adjective].sort_by(&:id), list.words.sort_by(&:id)
  end

  test "shows all words on initial load by cologne phonetics" do
    create(:noun, name: "Fahrrad")
    visit search_path
    assert_text "Fahrrad"
  end

  test "removes words phonetically by cologne phonetics" do
    create(:noun, name: "Fahrrad")
    visit search_path("filterrific[filter_home]": "Hau")
    assert_no_text "Fahrrad"
  end

  test "finds exact phonetic match by cologne phonetics" do
    create(:noun, name: "Fahrrad")
    visit search_path("filterrific[filter_home]": "Vahrad")
    assert_text "Fahrrad"
  end
end
