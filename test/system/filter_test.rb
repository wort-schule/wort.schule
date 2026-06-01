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
    disable_form_auto_submit
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

    # Stop the filter form's `form-submission` Stimulus controller from
    # auto-fetching on each input event. With it enabled, `fill_in "ab"`
    # fires a fetch per keystroke and `force_select_value` fires a third —
    # all racing, all replacing #words via turbo_stream in arbitrary order.
    # Apply all filter values silently, then submit once via the apply
    # button for a single deterministic response.
    disable_form_auto_submit

    fill_in "filterrific[filter_wordstarts]", with: "ab"
    force_select_value("filterrific[filter_keywords][conjunction]", "and")
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
    disable_form_auto_submit
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

    # Stop the filter form's `form-submission` Stimulus controller from
    # firing a fetch on every input event. Otherwise `fill_in "ab"` fires
    # one fetch per keystroke, each turbo_stream response re-renders the
    # #add_words_to_list frame, and a click that lands during the re-render
    # raises ObsoleteNode (or "submits with no list_id" → 404 → no flash).
    # Set fields silently, then click apply for one deterministic submit.
    disable_form_auto_submit

    fill_in "filterrific[filter_wordstarts]", with: "ab"
    find_button(t("filter.apply"), visible: false).trigger("click")

    assert_empty list.words

    assert_text "Abend"
    assert_text "abbauen"
    assert_text "abstrakt"

    force_reveal!
    assert_selector "select#list_id", visible: true

    # Selecting the list dispatches a `change` that re-renders the
    # #add_words_to_list turbo_frame; a click that lands during that
    # re-render detaches the "add" button and raises ObsoleteNode. Retry the
    # select-and-submit as a unit and assert the outcome inside the block, so
    # a click swallowed by the re-render is retried instead of silently lost.
    with_node_churn_retry do
      force_select_value("list_id", list.id.to_s)
      click_on t("words.show.lists.add")

      assert_text t("filter.added_words_to_list", count: 3)
    end

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
