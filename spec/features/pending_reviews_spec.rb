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
end
