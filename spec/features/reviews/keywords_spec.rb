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
    within '[data-toggle-buttons-target="list"]' do
      expect(page.find_all("button").map(&:text)).to match_array ["Neues Stichwort", word.name]

      # No keywords are selected by default, so we select both
      click_on "Neues Stichwort"
      click_on word.name
    end

    expect do
      click_on I18n.t("reviews.show.actions.confirm")
    end.to change(Review, :count).by(1)
      .and change(WordImport, :count).by(1)

    # After one review, change should be applied immediately (REVIEWS_REQUIRED=1)
    expect(edit.reload.change_group.state).to eq "confirmed"
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

    # Reviewer adds a new keyword and confirms
    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name

    # No keywords are selected by default, so we select the suggestions first
    within '[data-toggle-buttons-target="list"]' do
      click_on "Neues Stichwort"
      click_on word.name
    end

    # Add a new keyword
    fill_in "tomselect-1-ts-control", with: keyword.name
    within ".ts-dropdown" do
      find(:css, "[data-value=\"#{keyword.id}\"]").click
    end
    # Click somewhere else to close the dropdown
    find("body").click
    # The new keyword is automatically added and selected
    click_on I18n.t("reviews.show.actions.confirm")

    # Adding a keyword creates a new edit, get the latest one
    edit = WordAttributeEdit.order(:created_at).last
    expect(JSON.parse(edit.value)).to match_array ["Neues Stichwort", word.id.to_s, keyword.id.to_s]

    # Another reviewer confirms the edited value (with REVIEWS_REQUIRED=1, only need 1 more)
    login_as other_admin
    visit reviews_path
    within '[data-toggle-buttons-target="list"]' do
      expect(page.find_all("button").map(&:text)).to match_array ["Neues Stichwort", word.name, keyword.name]

      # No keywords are selected by default, so we select all three
      click_on "Neues Stichwort"
      click_on word.name
      click_on keyword.name
    end
    expect do
      click_on I18n.t("reviews.show.actions.confirm")
    end.to change(Review, :count).by(1)
      .and change(WordImport, :count).by(1)

    # Now it's applied
    expect(edit.reload.change_group.state).to eq "confirmed"
    expect(edit.word.keywords.map(&:name)).to match_array [word.name, keyword.name]
    expect(WordImport.all).to match_array [
      have_attributes(
        name: "Neues Stichwort"
      )
    ]
  end
end
