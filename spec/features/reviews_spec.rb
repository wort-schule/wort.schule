# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews" do
  let(:me) { create :admin }
  let(:other_admin) { create :admin }

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

    login_as create(:admin)
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
    click_on I18n.t("reviews.show.actions.edit")

    fill_in I18n.t("reviews.new.new_proposal"), with: proposal
    click_on I18n.t("helpers.submit.update")
    expect(edit.reload.current_value).not_to eq proposal

    login_as other_admin
    visit reviews_path
    expect(page).to have_content proposal
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).not_to eq proposal

    login_as create(:admin)
    visit reviews_path
    expect(page).to have_content proposal
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
    click_on I18n.t("reviews.show.actions.edit")

    fill_in I18n.t("reviews.new.new_proposal"), with: proposal
    click_on I18n.t("helpers.submit.update")
    expect(edit.reload.current_value).not_to eq proposal

    login_as me
    visit reviews_path
    expect(page).to have_content I18n.t("reviews.index.empty.title")

    login_as other_admin
    visit reviews_path
    expect(page).to have_content I18n.t("reviews.index.empty.title")

    Reviewable::REVIEWS_REQUIRED.times do
      login_as create(:admin)
      visit reviews_path
      expect(page).to have_content edit.word.name
      click_on I18n.t("reviews.show.actions.confirm")
    end

    expect(edit.reload.current_value).to eq proposal
  end
end
