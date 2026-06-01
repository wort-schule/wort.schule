# frozen_string_literal: true

require "test_helper"

class ReviewFiltersControllerTest < ActionDispatch::IntegrationTest
  test "toggling new words off disables the flag" do
    admin = create(:admin, review_new_words: true)
    sign_in admin

    patch review_filter_path, params: {review_type: "new_word"}

    assert_redirected_to reviews_path
    refute admin.reload.review_new_words?
  end

  test "toggling new words on enables the flag" do
    admin = create(:admin, review_new_words: false)
    sign_in admin

    patch review_filter_path, params: {review_type: "new_word"}

    assert admin.reload.review_new_words?
  end

  test "toggling an unselected attribute adds its canonical key" do
    admin = create(:admin, review_attributes: [])
    sign_in admin

    patch review_filter_path, params: {review_type: "keywords"}

    assert_includes admin.reload.review_attributes, "noun.keywords"
  end

  test "toggling a selected attribute removes it" do
    admin = create(:admin, review_attributes: ["noun.keywords"])
    sign_in admin

    patch review_filter_path, params: {review_type: "keywords"}

    assert_equal [], admin.reload.review_attributes
  end

  test "toggling one selected attribute leaves the others untouched" do
    admin = create(:admin, review_attributes: ["noun.keywords", "noun.synonyms"])
    sign_in admin

    patch review_filter_path, params: {review_type: "keywords"}

    assert_equal ["noun.synonyms"], admin.reload.review_attributes
  end

  test "ignores an unknown review type" do
    admin = create(:admin, review_attributes: ["noun.keywords"])
    sign_in admin

    patch review_filter_path, params: {review_type: "does_not_exist"}

    assert_redirected_to reviews_path
    assert_equal ["noun.keywords"], admin.reload.review_attributes
  end
end
