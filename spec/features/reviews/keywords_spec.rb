# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews for keywords" do
  let(:me) { create :admin, review_attributes: Llm::Attributes.keys_with_types }
  let(:other_admin) { create :admin, review_attributes: Llm::Attributes.keys_with_types }
  let(:word) { create(:noun, name: "Haus") }

  it "confirms a change", :js do
    edit = create(:word_attribute_edit, attribute_name: "keywords", value: ["Neues Stichwort", word.id.to_s].to_json)
    expect(edit.word.keywords.map(&:name)).to be_empty
    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name
    click_on "Neues Stichwort"
    click_on word.name
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as other_admin
    visit reviews_path
    within '[data-toggle-buttons-target="list"]' do
      expect(page.find_all("button").map(&:text)).to match_array ["Neues Stichwort", word.name]
    end
    click_on "Neues Stichwort"
    click_on word.name
    expect do
      click_on I18n.t("reviews.show.actions.confirm")
    end.to change(Review, :count).by(1)
      .and change(WordImport, :count).by(1)

    expect(edit.word.keywords.map(&:name)).to match [word.name]
    expect(WordImport.all).to match_array [
      have_attributes(
        name: "Neues Stichwort"
      )
    ]
  end

  it "adds a new keyword during review", :js do
    keyword = create(:noun, name: "Hase")
    edit = create(:word_attribute_edit, attribute_name: "keywords", value: ["Neues Stichwort", word.id].to_json)
    expect(edit.word.keywords.map(&:name)).to be_empty
    expect(edit.reload.current_value).not_to eq edit.proposed_value

    # First reviewer adds a new keyword
    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name

    click_on "Neues Stichwort"
    click_on word.name
    fill_in "tomselect-1-ts-control", with: keyword.name
    within ".ts-dropdown" do
      find(:css, "[data-value=\"#{keyword.id}\"]").click
    end
    # Click somewhere to close autocomplete popup
    click_on "Hase"
    # Re-enable selection again
    click_on "Hase"
    click_on I18n.t("reviews.show.actions.confirm")

    edit = WordAttributeEdit.order(:created_at).last
    expect(JSON.parse(edit.value)).to match_array ["Neues Stichwort", word.id.to_s, keyword.id.to_s]
    expect(edit.reload.current_value).not_to eq edit.proposed_value

    # Second reviewer confirms
    login_as other_admin
    visit reviews_path
    within '[data-toggle-buttons-target="list"]' do
      expect(page.find_all("button").map(&:text)).to match_array ["Neues Stichwort", word.name, keyword.name]
    end
    click_on I18n.t("reviews.show.actions.confirm")

    # Third reviewer confirms
    login_as create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    visit reviews_path
    within '[data-toggle-buttons-target="list"]' do
      expect(page.find_all("button").map(&:text)).to match_array ["Neues Stichwort", word.name, keyword.name]
    end
    expect do
      click_on I18n.t("reviews.show.actions.confirm")
    end.to change(Review, :count).by(1)
      .and change(WordImport, :count).by(1)

    # Final checks
    expect(JSON.parse(edit.reload.value)).to match ["Neues Stichwort", word.id.to_s, keyword.id.to_s]
    expect(edit.word.keywords.map(&:name)).to match_array [word.name, keyword.name]
    expect(WordImport.all).to match_array [
      have_attributes(
        name: "Neues Stichwort"
      )
    ]
  end
end
