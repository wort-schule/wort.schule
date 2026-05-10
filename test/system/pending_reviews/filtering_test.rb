# frozen_string_literal: true

require "application_system_test_case"

class PendingReviewsFilteringTest < ApplicationSystemTestCase
  setup do
    @me = create(:admin)
  end

  test "filters the table by exact word name" do
    word1 = create(:noun, name: "Apple")
    create(:word_attribute_edit, word: word1)

    word2 = create(:noun, name: "Banana")
    create(:word_attribute_edit, word: word2)

    login_as @me
    visit pending_reviews_path

    assert_text "Apple"
    assert_text "Banana"

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "Apple"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text "Apple"
    assert_no_text "Banana"
    assert_text I18n.t("pending_reviews.index.filtered_by", filter: "Apple")
  end

  test "filters the table with wildcard patterns" do
    word1 = create(:noun, name: "TestWord1")
    create(:word_attribute_edit, word: word1)

    word2 = create(:noun, name: "TestWord2")
    create(:word_attribute_edit, word: word2)

    word3 = create(:noun, name: "OtherWord")
    create(:word_attribute_edit, word: word3)

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "Test*"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text "TestWord1"
    assert_text "TestWord2"
    assert_no_text "OtherWord"
    assert_text "Zeige 1-2 von 2"
  end

  test "can clear the filter" do
    word1 = create(:noun, name: "Apple")
    create(:word_attribute_edit, word: word1)

    word2 = create(:noun, name: "Banana")
    create(:word_attribute_edit, word: word2)

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "Apple"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text "Apple"
    assert_no_text "Banana"

    click_link I18n.t("pending_reviews.index.clear_filter")

    assert_text "Apple"
    assert_text "Banana"
    assert_no_text I18n.t("pending_reviews.index.filtered_by", filter: "Apple")
  end

  test "preserves filter when changing pagination" do
    30.times do |i|
      word = create(:noun, name: "FilterTest #{i}")
      create(:word_attribute_edit, word:)
    end

    word = create(:noun, name: "OtherWord")
    create(:word_attribute_edit, word:)

    login_as @me
    visit pending_reviews_path(per_page: 10)

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "FilterTest*"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text "Zeige 1-10 von 30"
    assert_no_text "OtherWord"

    within(first(".pagination-wrapper")) do
      click_link "2"
    end

    assert_text "Zeige 11-20 von 30"
    assert_no_text "OtherWord"
    assert_text I18n.t("pending_reviews.index.filtered_by", filter: "FilterTest*")
  end

  test "preserves filter when sorting" do
    word1 = create(:noun, name: "Apple")
    create(:word_attribute_edit, word: word1, created_at: 2.days.ago)

    word2 = create(:noun, name: "Apricot")
    create(:word_attribute_edit, word: word2, created_at: 1.day.ago)

    word3 = create(:noun, name: "Banana")
    create(:word_attribute_edit, word: word3, created_at: 3.days.ago)

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "Ap*"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text "Apple"
    assert_text "Apricot"
    assert_no_text "Banana"

    within("thead") do
      click_link I18n.t("pending_reviews.index.word")
    end

    assert_text "Apple"
    assert_text "Apricot"
    assert_no_text "Banana"
    assert_text I18n.t("pending_reviews.index.filtered_by", filter: "Ap*")
  end

  test "filters new word proposals as well" do
    create(:new_word, name: "NewApple")
    create(:new_word, name: "NewBanana")

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "NewApple"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text "NewApple"
    assert_no_text "NewBanana"
  end

  test "has filter collapsed by default" do
    word = create(:noun, name: "TestWord")
    create(:word_attribute_edit, word:)

    login_as @me
    visit pending_reviews_path

    assert_selector "details.filter-section:not([open])"
  end

  test "can expand the filter section" do
    word = create(:noun, name: "TestWord")
    create(:word_attribute_edit, word:)

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    assert_field I18n.t("pending_reviews.index.filter_table_placeholder")
  end

  test "filters by word type (Wortart)" do
    noun = create(:noun, name: "TestNoun")
    create(:word_attribute_edit, word: noun)

    verb = create(:verb, name: "TestVerb")
    create(:word_attribute_edit, word: verb)

    adjective = create(:adjective, name: "TestAdjective")
    create(:word_attribute_edit, word: adjective)

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    select "Noun", from: I18n.t("pending_reviews.index.word_type_filter")
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text "TestNoun"
    assert_no_text "TestVerb"
    assert_no_text "TestAdjective"
  end

  test "filters by keywords (Stichwörter)" do
    keyword1 = create(:noun, name: "Keyword1")
    keyword2 = create(:noun, name: "Keyword2")

    word1 = create(:noun, name: "Word1")
    create(:word_attribute_edit, word: word1, attribute_name: "keywords", value: [keyword1.id].to_json)

    word2 = create(:noun, name: "Word2")
    create(:word_attribute_edit, word: word2, attribute_name: "keywords", value: [keyword2.id].to_json)

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.keyword_filter"), with: "Keyword1"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text "Word1"
    assert_no_text "Word2"
  end

  test "filters by review type (Reviewtyp)" do
    word = create(:noun, name: "EditWord")
    create(:word_attribute_edit, word:)

    create(:new_word, name: "NewWordProposal")

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    select I18n.t("pending_reviews.index.review_type_attribute_edit"), from: I18n.t("pending_reviews.index.review_type_filter")
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text "EditWord"
    assert_no_text "NewWordProposal"

    click_link I18n.t("pending_reviews.index.clear_filter")
    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click
    select I18n.t("pending_reviews.index.review_type_new_word"), from: I18n.t("pending_reviews.index.review_type_filter")
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text "NewWordProposal"
    assert_no_text "EditWord"
  end

  test "shows filter examples to help users" do
    word = create(:noun, name: "TestWord")
    create(:word_attribute_edit, word:)

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    assert_text I18n.t("pending_reviews.index.filter_examples")
  end
end
