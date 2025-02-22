# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews for enriched attributes" do
  let(:me) { create :admin, review_attributes: Llm::Attributes.keys_with_types }
  let(:other_admin) { create :admin, review_attributes: Llm::Attributes.keys_with_types }

  it "confirms a change" do
    edit = create(:word_attribute_edit)
    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as other_admin
    visit reviews_path
    expect(page).to have_content edit.word.name
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).to eq edit.proposed_value
  end

  it "skips a change" do
    edit = create(:word_attribute_edit)
    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name
    click_on I18n.t("reviews.show.actions.skip")

    visit reviews_path
    expect(page).to have_content I18n.t("reviews.index.empty.title")
    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as other_admin
    visit reviews_path
    expect(page).to have_content edit.word.name
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    visit reviews_path
    expect(page).to have_content edit.word.name
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).to eq edit.proposed_value
  end

  it "edits a change" do
    edit = create(:word_attribute_edit)
    proposal = "New word"
    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name

    fill_in "change_group[word_attribute_edits_attributes][0][value]", with: proposal
    click_on I18n.t("reviews.show.actions.confirm")
    expect(edit.reload.current_value).not_to eq proposal

    login_as other_admin
    visit reviews_path
    expect(page).to have_field "change_group[word_attribute_edits_attributes][0][value]", with: proposal
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).not_to eq proposal

    login_as create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    visit reviews_path
    expect(page).to have_field "change_group[word_attribute_edits_attributes][0][value]", with: proposal
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).to eq proposal
  end

  it "edits a partially approved change" do
    edit = create(:word_attribute_edit)
    proposal = "New word"
    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name
    click_on I18n.t("reviews.show.actions.confirm")

    visit reviews_path
    expect(page).to have_content I18n.t("reviews.index.empty.title")

    login_as other_admin
    visit reviews_path
    expect(page).to have_content edit.word.name

    fill_in "change_group[word_attribute_edits_attributes][0][value]", with: proposal
    click_on I18n.t("reviews.show.actions.confirm")
    expect(edit.reload.current_value).not_to eq proposal

    login_as me
    visit reviews_path
    expect(page).to have_content I18n.t("reviews.index.empty.title")

    login_as other_admin
    visit reviews_path
    expect(page).to have_content I18n.t("reviews.index.empty.title")

    Reviewable::REVIEWS_REQUIRED.times do
      login_as create(:admin, review_attributes: Llm::Attributes.keys_with_types)
      visit reviews_path
      expect(page).to have_content edit.word.name
      click_on I18n.t("reviews.show.actions.confirm")
    end

    expect(edit.reload.current_value).to eq proposal
  end

  it "does not allow to send in an empty proposal" do
    edit = create(:word_attribute_edit, value: "")
    proposal = ""

    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name

    fill_in "change_group[word_attribute_edits_attributes][0][value]", with: proposal
    expect do
      click_on I18n.t("reviews.show.actions.confirm")
    end.to_not change(Review, :count)

    expect(page).to have_content I18n.t("errors.messages.blank")
  end

  it "edits and confirms a boolean change" do
    edit = create(:word_attribute_edit, attribute_name: "singularetantum", value: "false")
    proposal = true

    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name

    expect(page).to have_unchecked_field "change_group[word_attribute_edits_attributes][0][value]"
    check "change_group[word_attribute_edits_attributes][0][value]"
    click_on I18n.t("reviews.show.actions.confirm")
    expect(edit.reload.current_value).not_to eq proposal
    expect(WordAttributeEdit.last.value).to eq "true"

    login_as other_admin
    visit reviews_path
    expect(page).to have_checked_field "change_group[word_attribute_edits_attributes][0][value]"
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).not_to eq proposal
    expect(WordAttributeEdit.last.value).to eq "true"

    login_as create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    visit reviews_path
    expect(page).to have_checked_field "change_group[word_attribute_edits_attributes][0][value]"
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).to eq proposal
  end

  it "edits and confirms an array change", js: true do
    edit = create(:word_attribute_edit, attribute_name: "synonyms", value: '["Katze", "Kaninchen"]')
    cat = create(:noun, name: "Katze")
    rabbit = create(:noun, name: "Kaninchen")
    proposal = "Katze"
    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name

    within '[data-toggle-buttons-target="list"]' do
      expect(page.find_all("button").map(&:text)).to match_array [cat.name, rabbit.name]

      click_on cat.name

      expect(page.find_all('button[class~="bg-primary"]').map(&:text)).to match_array [cat.name]
    end

    expect do
      click_on I18n.t("reviews.show.actions.confirm")
    end.to change(Review, :count).by(1)
    expect(edit.reload.current_value).not_to eq proposal
    expect(WordAttributeEdit.last.value).to eq '["Katze"]'

    login_as other_admin
    visit reviews_path
    within '[data-toggle-buttons-target="list"]' do
      expect(page.find_all("button").map(&:text)).to match_array [cat.name]
    end
    expect do
      click_on I18n.t("reviews.show.actions.confirm")
    end.to change(Review, :count).by(1)

    expect(edit.reload.current_value).not_to eq proposal
    expect(WordAttributeEdit.last.value).to eq '["Katze"]'

    login_as create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    visit reviews_path
    within '[data-toggle-buttons-target="list"]' do
      expect(page.find_all("button").map(&:text)).to match_array [cat.name]
    end
    expect do
      click_on I18n.t("reviews.show.actions.confirm")
    end.to change(Review, :count).by(1)

    expect(edit.reload.current_value).to eq proposal
  end
end
