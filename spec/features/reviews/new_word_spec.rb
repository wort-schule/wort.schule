# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews for new words" do
  let(:me) { create :admin }

  it "chooses a duplicate word" do
    new_word = create(:new_word)
    duplicate_word = create(:noun, name: new_word.llm_name)

    login_as me
    visit reviews_path
    expect(page).to have_content new_word.name
    expect(page).to have_content new_word.topic

    expect do
      click_on I18n.t("reviews.duplicate_words_component.choose")
    end.to change(Review, :count).by(1)
      .and not_change(Word, :count)

    expect(new_word.reload).to have_attributes(
      duplicate_word:,
      created_word: nil
    )
  end

  it "skips the review" do
    new_word = create(:new_word)

    login_as me
    visit reviews_path
    expect(page).to have_content new_word.name
    expect(page).to have_content new_word.topic

    expect do
      click_on I18n.t("reviews.show.actions.skip")
    end.to change(Review, :count).by(1)
      .and not_change(Word, :count)

    expect(Review.last.state).to eq "skipped"
  end

  it "confirms the new word" do
    new_word = create(:new_word)

    login_as me
    visit reviews_path
    expect(page).to have_content new_word.name
    expect(page).to have_content new_word.topic

    expect do
      click_on I18n.t("reviews.new_word_component.create")
    end.to change(Review, :count).by(1)
      .and change(Word, :count).by(1)
      .and enqueue_job(EnrichWordJob)

    created_word = Word.last

    expect(created_word).to have_attributes(
      name: new_word.name,
      topics: match_array([
        have_attributes(name: new_word.topic)
      ])
    )

    expect(new_word.reload).to have_attributes(
      duplicate_word: nil,
      created_word:
    )
  end

  it "changes and creates the new word" do
    new_word = create(:new_word)
    corrected_name = "Kater"
    corrected_topic = "Lebewesen"

    login_as me
    visit reviews_path
    expect(page).to have_content new_word.name
    expect(page).to have_content new_word.topic

    fill_in NewWord.human_attribute_name(:name), with: corrected_name
    fill_in NewWord.human_attribute_name(:topic), with: corrected_topic

    expect do
      click_on I18n.t("reviews.new_word_component.create")
    end.to change(Review, :count).by(1)
      .and change(Word, :count).by(1)

    created_word = Word.last

    expect(created_word).to have_attributes(
      name: corrected_name,
      topics: match_array([
        have_attributes(name: corrected_topic)
      ])
    )

    expect(new_word.reload).to have_attributes(
      duplicate_word: nil,
      created_word:
    )
  end

  it "does not allow to create a word without name or topic" do
    new_word = create(:new_word)

    login_as me
    visit reviews_path
    expect(page).to have_content new_word.name
    expect(page).to have_content new_word.topic

    fill_in NewWord.human_attribute_name(:name), with: ""
    fill_in NewWord.human_attribute_name(:topic), with: ""

    expect do
      click_on I18n.t("reviews.new_word_component.create")
    end.to not_change(Review, :count)
      .and not_change(Word, :count)

    expect(page).to have_content(I18n.t("errors.messages.blank"))
    expect(new_word.reload.name).to be_present
    expect(new_word.topic).to be_present
  end

  it "does not create a new word if that word already exists" do
    new_word = create(:new_word)
    corrected_name = "Kater"
    corrected_topic = "Lebewesen"
    existing_word = create(:noun, name: corrected_name, topics: [build(:topic, name: corrected_topic)])

    login_as me
    visit reviews_path
    expect(page).to have_content new_word.name
    expect(page).to have_content new_word.topic

    fill_in NewWord.human_attribute_name(:name), with: corrected_name
    fill_in NewWord.human_attribute_name(:topic), with: corrected_topic

    expect do
      click_on I18n.t("reviews.new_word_component.create")
    end.to change(Review, :count).by(1)
      .and not_change(Word, :count)

    expect(Review.last.state).to eq "duplicate"

    expect(new_word.reload).to have_attributes(
      duplicate_word: existing_word,
      created_word: nil
    )
  end
end
