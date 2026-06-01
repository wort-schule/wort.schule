# frozen_string_literal: true

require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  test "re-rendering the review after an invalid proposal still loads the filter" do
    admin = create(:admin, review_attributes: ["noun.keywords"])
    sign_in admin
    edit = create(:word_attribute_edit, attribute_name: "keywords")

    patch review_path(edit.change_group), params: {
      state: "confirmed",
      change_group: {
        word_attribute_edits_attributes: {
          "0" => {id: edit.id, value: ""}
        }
      }
    }

    assert_response :unprocessable_entity
    assert_select "form[action=?]", review_filter_path
  end

  test "explains that types are deselected and shows the filter when pending reviews are filtered out" do
    admin = create(:admin, review_attributes: [], review_new_words: false)
    sign_in admin
    create(:new_word) # pending, but filtered out, so the queue is empty

    get reviews_path

    assert_response :success
    assert_select "h1", text: I18n.t("reviews.index.filtered.title")
    assert_select "form[action=?]", review_filter_path
  end

  test "shows the plain empty message and no filter when nothing is pending" do
    sign_in create(:admin)

    get reviews_path

    assert_response :success
    assert_select "h1", text: I18n.t("reviews.index.empty.title")
    assert_select "form[action=?]", review_filter_path, count: 0
  end
end
