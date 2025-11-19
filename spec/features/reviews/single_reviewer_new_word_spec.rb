# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Single reviewer confirming new word", :js do
  let(:admin) { create :admin, review_attributes: Llm::Attributes.keys_with_types }

  before do
    # Ensure only 1 review is required
    GlobalSetting.reviews_required = 1
  end

  it "creates the word immediately when a single reviewer confirms" do
    # Create a new word proposal
    new_word = create(:new_word, name: "TestWort", topic: "Tiere", word_type: "Noun")

    # Verify initial state
    expect(new_word.change_group.state).to eq "waiting_for_review"
    expect(Word.find_by(name: "TestWort")).to be_nil

    # Login and visit reviews page
    login_as admin
    visit reviews_path

    # Should see the new word proposal
    expect(page).to have_content "TestWort"
    expect(page).to have_content "Tiere"

    # Fill in the form fields (they should be pre-filled from the new_word data)
    # and click the create button
    click_button I18n.t("reviews.new_word_component.create")

    # After confirmation, check database state
    new_word.reload
    expect(new_word.change_group.state).to eq "created"
    expect(new_word.change_group.reviews.count).to eq 1
    expect(new_word.change_group.reviews.first.state).to eq "created"

    # Check that the word was created
    created_word = Word.find_by(name: "TestWort")
    expect(created_word).to be_present
    expect(created_word.type).to eq "Noun"
    expect(created_word.topics.first.name).to eq "Tiere"
    expect(new_word.created_word).to eq created_word

    # Should be redirected to next review or reviews index (if there are no more reviews)
    # The path will be either /seite/reviews (if no more reviews) or /seite/reviews/:id (if more reviews exist)
    expect(current_path).to match(%r{^/seite/reviews(/\d+)?$})
  end

  it "does not require a second review when reviews_required is 1" do
    new_word = create(:new_word, name: "EinzigesWort", topic: "Natur", word_type: "Noun")

    login_as admin
    visit reviews_path

    # Confirm the new word
    click_button I18n.t("reviews.new_word_component.create")

    # Should immediately create the word without requiring another review
    created_word = Word.find_by(name: "EinzigesWort")
    expect(created_word).to be_present

    # The change_group should be in "created" state, not waiting for more reviews
    new_word.reload
    expect(new_word.change_group.state).to eq "created"
  end
end
