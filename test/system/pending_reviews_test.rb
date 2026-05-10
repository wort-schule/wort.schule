# frozen_string_literal: true

require "application_system_test_case"

class PendingReviewsTest < ApplicationSystemTestCase
  setup do
    @me = create(:admin)
  end

  test "displays pending reviews with new word proposals without errors" do
    new_word = create(:new_word)

    login_as @me
    visit pending_reviews_path

    assert_text new_word.name
    assert_text new_word.topic
    assert_text I18n.t("pending_reviews.index.new")
  end

  test "displays pending reviews with word attribute edits" do
    word = create(:noun, meaning: "a male cat")
    create(:word_attribute_edit, word:)

    login_as @me
    visit pending_reviews_path

    assert_text word.name
    assert_text I18n.t("pending_reviews.index.attribute_edits", count: 1)
  end

  test "displays human-readable keyword names instead of IDs" do
    word = create(:noun, name: "Test Word")
    keyword1 = create(:noun, name: "Keyword 1")
    keyword2 = create(:noun, name: "Keyword 2")

    create(:word_attribute_edit, word:, attribute_name: "keywords", value: [keyword1.id, keyword2.id].to_json)

    login_as @me
    visit pending_reviews_path

    assert_text word.name
    assert_text "Keyword 1"
    assert_text "Keyword 2"
  end

  test "displays human-readable keyword names for comma-separated string format" do
    word = create(:noun, name: "Test Word 2")
    keyword1 = create(:noun, name: "Keyword A")
    keyword2 = create(:noun, name: "Keyword B")

    create(:word_attribute_edit, word:, attribute_name: "keywords", value: "\"#{keyword1.id}, #{keyword2.id}\"")

    login_as @me
    visit pending_reviews_path

    assert_text word.name
    assert_text "Keyword A"
    assert_text "Keyword B"
  end

  test "displays 250 items per page by default" do
    260.times do |i|
      word = create(:noun, name: "Word #{i.to_s.rjust(3, "0")}")
      create(:word_attribute_edit, word:, created_at: i.seconds.ago)
    end

    login_as @me
    visit pending_reviews_path

    assert_text "Zeige 1-250 von 260"

    assert_link "2"

    assert_link "Review starten", count: 250
  end

  test "allows changing the page size" do
    60.times do |i|
      word = create(:noun, name: "PaginationTest #{i}")
      create(:word_attribute_edit, word:)
    end

    login_as @me
    visit pending_reviews_path(per_page: 25)

    assert_text "PaginationTest 59"
    assert_text "PaginationTest 35"
    assert_no_text "PaginationTest 34"

    assert_link "3"
  end

  test "preserves per_page parameter when navigating pages" do
    60.times do |i|
      word = create(:noun, name: "NavTest #{i}")
      create(:word_attribute_edit, word:)
    end

    login_as @me
    visit pending_reviews_path(per_page: 20)

    first(:link, "2").click

    assert_text "NavTest 39"
    assert_text "NavTest 20"
    assert_no_text "NavTest 19"
    assert_no_text "NavTest 59"
  end

  test "preserves sorting when paginating" do
    word1 = create(:noun, name: "Oldest Word")
    create(:word_attribute_edit, word: word1, created_at: 3.days.ago)

    word2 = create(:noun, name: "Newest Word")
    create(:word_attribute_edit, word: word2, created_at: 1.day.ago)

    login_as @me
    visit pending_reviews_path(sort_by: "created_at", sort_direction: "asc")

    within("tbody tr:first-child") do
      assert_text "Oldest Word"
    end
  end

  test "displays a proper h1 heading" do
    login_as @me
    visit pending_reviews_path

    assert_css "h1", text: I18n.t("pending_reviews.index.title")
  end

  test "aligns filter buttons horizontally" do
    word = create(:noun, name: "TestWord")
    create(:word_attribute_edit, word:)

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "Test*"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    within(".filter-section") do
      filter_button_y = page.evaluate_script(<<~JS)
        document.querySelector('.filter-section input[type="submit"]').getBoundingClientRect().top
      JS

      clear_button_y = page.evaluate_script(<<~JS)
        Array.from(document.querySelectorAll('.filter-section a.button'))
          .find(el => el.textContent.includes('#{I18n.t("pending_reviews.index.clear_filter")}'))
          .getBoundingClientRect().top
      JS

      assert (filter_button_y - clear_button_y).abs <= 2
    end
  end

  test "has pagination controls at top and bottom of table" do
    260.times do |i|
      word = create(:noun, name: "Word #{i.to_s.rjust(3, "0")}")
      create(:word_attribute_edit, word:)
    end

    login_as @me
    visit pending_reviews_path(per_page: 50)

    pagination_sections = all(".pagination-wrapper")
    assert_equal 2, pagination_sections.count

    pagination_sections.each do |section|
      within(section) do
        assert_link "2"
      end
    end
  end
end
