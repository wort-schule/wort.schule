# frozen_string_literal: true

require "application_system_test_case"

class ReviewsWordAttributeEditTest < ApplicationSystemTestCase
  setup do
    @me = create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    @other_admin = create(:admin, review_attributes: Llm::Attributes.keys_with_types)
  end

  test "confirms a change" do
    edit = create(:word_attribute_edit)
    refute_equal edit.proposed_value, edit.reload.current_value

    login_as @me
    visit reviews_path
    assert_text edit.word.name
    click_on I18n.t("reviews.show.actions.confirm")

    assert_equal edit.proposed_value, edit.reload.current_value
  end

  test "skips a change" do
    edit = create(:word_attribute_edit)
    refute_equal edit.proposed_value, edit.reload.current_value

    login_as @me
    visit reviews_path
    assert_text edit.word.name
    click_on I18n.t("reviews.show.actions.skip")

    visit reviews_path
    assert_text I18n.t("reviews.index.empty.title")
    refute_equal edit.proposed_value, edit.reload.current_value

    login_as @other_admin
    visit reviews_path
    assert_text edit.word.name
    click_on I18n.t("reviews.show.actions.confirm")

    assert_equal edit.proposed_value, edit.reload.current_value
  end

  test "edits a change" do
    edit = create(:word_attribute_edit)
    proposal = "New word"
    refute_equal edit.proposed_value, edit.reload.current_value

    login_as @me
    visit reviews_path
    assert_text edit.word.name

    fill_in "change_group[word_attribute_edits_attributes][0][value]", with: proposal
    click_on I18n.t("reviews.show.actions.confirm")

    latest_edit = WordAttributeEdit.order(:created_at).last
    assert_equal proposal, latest_edit.proposed_value
    refute_equal proposal, latest_edit.current_value

    login_as @other_admin
    visit reviews_path
    assert_field "change_group[word_attribute_edits_attributes][0][value]", with: proposal
    click_on I18n.t("reviews.show.actions.confirm")

    assert_equal proposal, latest_edit.reload.current_value
  end

  test "does not allow to send in an empty proposal" do
    edit = create(:word_attribute_edit, value: "")
    proposal = ""

    login_as @me
    visit reviews_path
    assert_text edit.word.name

    fill_in "change_group[word_attribute_edits_attributes][0][value]", with: proposal
    assert_no_difference -> { Review.count } do
      click_on I18n.t("reviews.show.actions.confirm")
    end

    assert_text I18n.t("errors.messages.blank")
  end

  test "edits and confirms a boolean change" do
    edit = create(:word_attribute_edit, attribute_name: "singularetantum", value: "false")
    proposal = true

    login_as @me
    visit reviews_path
    assert_text edit.word.name

    assert_no_checked_field "change_group[word_attribute_edits_attributes][0][value]"
    check "change_group[word_attribute_edits_attributes][0][value]"
    click_on I18n.t("reviews.show.actions.confirm")

    latest_edit = WordAttributeEdit.order(:created_at).last
    assert_equal proposal, latest_edit.proposed_value
    refute_equal proposal, latest_edit.current_value
    assert_equal "true", latest_edit.value

    login_as @other_admin
    visit reviews_path
    assert_checked_field "change_group[word_attribute_edits_attributes][0][value]"
    click_on I18n.t("reviews.show.actions.confirm")

    assert_equal proposal, latest_edit.reload.current_value
  end

  test "edits and confirms an array change" do
    edit = create(:word_attribute_edit, attribute_name: "synonyms", value: '["Katze", "Kaninchen"]')
    cat = create(:noun, name: "Katze")
    rabbit = create(:noun, name: "Kaninchen")
    proposal = "Katze"
    refute_equal edit.proposed_value, edit.reload.current_value

    login_as @me
    visit reviews_path
    assert_text edit.word.name

    within '[data-toggle-buttons-target="list"]' do
      assert_equal [cat.name, rabbit.name].sort, page.find_all("button").map(&:text).sort

      click_on cat.name

      assert_equal [cat.name], page.find_all('button[class~="bg-primary"]').map(&:text)
    end

    assert_difference -> { Review.count }, +1 do
      click_on I18n.t("reviews.show.actions.confirm")
    end

    latest_edit = WordAttributeEdit.order(:created_at).last
    assert_equal [proposal], latest_edit.proposed_value
    refute_equal [proposal], latest_edit.current_value
    assert_equal '["Katze"]', latest_edit.value

    login_as @other_admin
    visit reviews_path
    within '[data-toggle-buttons-target="list"]' do
      assert_equal [cat.name], page.find_all("button").map(&:text)

      click_on cat.name
    end
    assert_difference -> { Review.count }, +1 do
      click_on I18n.t("reviews.show.actions.confirm")
    end

    assert_equal proposal, latest_edit.reload.current_value
  end
end
