# frozen_string_literal: true

require "application_system_test_case"

class PendingReviewsDeletionTest < ApplicationSystemTestCase
  setup do
    @me = create(:admin)
  end

  test "shows delete button only when filters are active" do
    word1 = create(:noun, name: "DeleteMe")
    create(:word_attribute_edit, word: word1)

    login_as @me
    visit pending_reviews_path

    assert_no_css ".button.danger", text: "Gefilterte Ergebnisse löschen"

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click
    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "DeleteMe"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_css ".button.danger", text: "Gefilterte Ergebnisse löschen"
  end

  test "can delete filtered results with modal confirmation" do
    word1 = create(:noun, name: "DeleteMe")
    change_group1 = create(:word_attribute_edit, word: word1).change_group

    word2 = create(:noun, name: "KeepMe")
    change_group2 = create(:word_attribute_edit, word: word2).change_group

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "DeleteMe"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    find(".button.danger", text: "Gefilterte Ergebnisse löschen").click

    within("dialog") do
      assert_text I18n.t("pending_reviews.index.confirm_deletion", count: 1)
    end

    within("dialog") do
      click_button I18n.t("pending_reviews.index.confirm_delete")
    end

    assert_text I18n.t("pending_reviews.index.deletion_success", count: 1)

    refute ChangeGroup.exists?(change_group1.id)
    assert ChangeGroup.exists?(change_group2.id)
  end

  test "deletes change groups matching wildcard pattern" do
    word1 = create(:noun, name: "TestWord1")
    change_group1 = create(:word_attribute_edit, word: word1).change_group

    word2 = create(:noun, name: "TestWord2")
    change_group2 = create(:word_attribute_edit, word: word2).change_group

    word3 = create(:noun, name: "KeepThis")
    change_group3 = create(:word_attribute_edit, word: word3).change_group

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "TestWord*"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    find(".button.danger", text: "Gefilterte Ergebnisse löschen").click

    within("dialog") do
      assert_text I18n.t("pending_reviews.index.confirm_deletion", count: 2)
    end

    within("dialog") do
      click_button I18n.t("pending_reviews.index.confirm_delete")
    end

    assert_text I18n.t("pending_reviews.index.deletion_success", count: 2)

    refute ChangeGroup.exists?(change_group1.id)
    refute ChangeGroup.exists?(change_group2.id)
    assert ChangeGroup.exists?(change_group3.id)

    assert_text "KeepThis"
  end

  test "does not show delete button when no matches found for filter" do
    word = create(:noun, name: "ExistingWord")
    create(:word_attribute_edit, word:)

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "NonExistent*"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    assert_text I18n.t("pending_reviews.index.no_pending_reviews")
    assert_no_css ".button.danger", text: "Gefilterte Ergebnisse löschen"
  end

  test "allows canceling deletion from modal" do
    word = create(:noun, name: "CancelTest")
    change_group = create(:word_attribute_edit, word:).change_group

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "CancelTest"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    find(".button.danger", text: "Gefilterte Ergebnisse löschen").click

    within("dialog") do
      click_button I18n.t("pending_reviews.index.cancel")
    end

    assert ChangeGroup.exists?(change_group.id)
    assert_text "CancelTest"
  end

  test "handles deletion of new word proposals" do
    new_word1 = create(:new_word, name: "NewWord1")
    change_group1 = new_word1.change_group

    new_word2 = create(:new_word, name: "NewWord2")
    change_group2 = new_word2.change_group

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "NewWord1"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    find(".button.danger", text: "Gefilterte Ergebnisse löschen").click

    within("dialog") do
      click_button I18n.t("pending_reviews.index.confirm_delete")
    end

    refute ChangeGroup.exists?(change_group1.id)
    assert ChangeGroup.exists?(change_group2.id)
  end

  test "handles deletion of new word proposals with unlisted keywords" do
    word_import = create(:word_import)

    new_word = create(:new_word, name: "NewWordWithKeyword")
    change_group = new_word.change_group

    keyword_word = create(:noun, name: "KeywordReference")
    unlisted_keyword = UnlistedKeyword.create!(
      word: keyword_word,
      word_import: word_import,
      new_word: new_word,
      state: "new"
    )

    login_as @me
    visit pending_reviews_path

    find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

    fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "NewWordWithKeyword"
    click_button I18n.t("pending_reviews.index.filter_table_button")

    find(".button.danger", text: "Gefilterte Ergebnisse löschen").click

    within("dialog") do
      click_button I18n.t("pending_reviews.index.confirm_delete")
    end

    refute ChangeGroup.exists?(change_group.id)
    refute NewWord.exists?(new_word.id)
    refute UnlistedKeyword.exists?(unlisted_keyword.id)
  end
end
