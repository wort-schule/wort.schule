# frozen_string_literal: true

require "rails_helper"

RSpec.describe "pending reviews page" do
  let(:me) { create :admin }

  it "displays pending reviews with new word proposals without errors" do
    new_word = create(:new_word)

    login_as me
    visit pending_reviews_path

    expect(page).to have_content new_word.name
    expect(page).to have_content new_word.topic
    expect(page).to have_content I18n.t("pending_reviews.index.new")
  end

  it "displays pending reviews with word attribute edits" do
    word = create(:noun, meaning: "a male cat")
    create(:word_attribute_edit, word:)

    login_as me
    visit pending_reviews_path

    expect(page).to have_content word.name
    expect(page).to have_content I18n.t("pending_reviews.index.attribute_edits", count: 1)
  end

  it "displays human-readable keyword names instead of IDs" do
    word = create(:noun, name: "Test Word")
    keyword1 = create(:noun, name: "Keyword 1")
    keyword2 = create(:noun, name: "Keyword 2")

    # Create an edit with keyword IDs
    create(:word_attribute_edit, word:, attribute_name: "keyword_ids", value: [keyword1.id, keyword2.id].to_json)

    login_as me
    visit pending_reviews_path

    expect(page).to have_content word.name
    # Verify we see the keyword names, not the IDs
    expect(page).to have_content "Keyword 1"
    expect(page).to have_content "Keyword 2"
    # Make sure IDs are not shown
    expect(page).not_to have_content "Stichwörter: #{keyword1.id}"
  end
end
