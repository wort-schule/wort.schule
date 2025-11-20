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

  it "discards the review" do
    original_env = ENV.to_hash
    ENV.update("REVIEW_EXCEPTION_MAIL" => "muster@example.com")

    new_word = create(:new_word)

    login_as me
    visit reviews_path
    expect(page).to have_content new_word.name
    expect(page).to have_content new_word.topic

    expect do
      click_on I18n.t("reviews.show.actions.discard")
    end.to change(Review, :count).by(1)
      .and not_change(Word, :count)
      .and enqueue_job(ActionMailer::MailDeliveryJob)

    expect(Review.last.state).to eq "discarded"
  ensure
    ENV.replace(original_env)
  end

  it "confirms the new word", :js do
    topic = create(:topic, name: "Tiere")
    new_word = create(:new_word, topic: topic.name)

    login_as me
    visit reviews_path
    expect(page).to have_content new_word.name

    # Topic should already be selected in the Tom-Select
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

  it "changes and creates the new word", :js do
    create(:topic, name: "Tiere")
    corrected_topic = create(:topic, name: "Lebewesen")
    new_word = create(:new_word, topic: "Tiere")
    corrected_name = "Kater"

    login_as me
    visit reviews_path
    expect(page).to have_content new_word.name

    fill_in NewWord.human_attribute_name(:name), with: corrected_name

    # Clear current selection and select new topic using Tom-Select
    find("#change_group_new_word_attributes_topic + .ts-wrapper .ts-control").click
    find(".ts-dropdown .option", text: corrected_topic.name).click
    find(".ts-control input").send_keys(:escape)

    expect do
      click_on I18n.t("reviews.new_word_component.create")
    end.to change(Review, :count).by(1)
      .and change(Word, :count).by(1)

    created_word = Word.last

    expect(created_word).to have_attributes(
      name: corrected_name,
      topics: match_array([
        have_attributes(name: corrected_topic.name)
      ])
    )

    expect(new_word.reload).to have_attributes(
      duplicate_word: nil,
      created_word:
    )
  end

  it "shows topic as Tom-Select with existing topics", :js do
    create(:topic, name: "Tiere")
    create(:topic, name: "Pflanzen")
    new_word = create(:new_word, topic: "")

    login_as me
    visit review_path(new_word.change_group)

    # Click on the Tom-Select control to open dropdown
    find("#change_group_new_word_attributes_topic + .ts-wrapper .ts-control").click

    # Both topics should be available in the dropdown
    expect(page).to have_css(".ts-dropdown .option", text: "Tiere")
    expect(page).to have_css(".ts-dropdown .option", text: "Pflanzen")
  end

  it "creates a new word with empty topic field initially", :js do
    # Simulate a new word created from keyword review (topic is empty)
    new_word = create(:new_word, topic: "")
    existing_topic = create(:topic, name: "Tiere")

    login_as me
    visit review_path(new_word.change_group)
    expect(page).to have_content new_word.name

    # Topic field should be empty initially and use Tom-Select
    fill_in NewWord.human_attribute_name(:name), with: "Hund"

    # Select existing topic from Tom-Select dropdown
    find("#change_group_new_word_attributes_topic + .ts-wrapper .ts-control").click
    find(".ts-dropdown .option", text: existing_topic.name).click

    expect do
      click_on I18n.t("reviews.new_word_component.create")
    end.to change(Review, :count).by(1)
      .and change(Word, :count).by(1)

    created_word = Word.last
    expect(created_word).to have_attributes(
      name: "Hund",
      topics: match_array([
        have_attributes(name: existing_topic.name)
      ])
    )
  end

  it "does not create a new word if that word already exists", :js do
    create(:topic, name: "Tiere")
    corrected_topic = create(:topic, name: "Lebewesen")
    new_word = create(:new_word, topic: "Tiere")
    corrected_name = "Kater"
    existing_word = create(:noun, name: corrected_name, topics: [corrected_topic])

    login_as me
    visit reviews_path
    expect(page).to have_content new_word.name

    fill_in NewWord.human_attribute_name(:name), with: corrected_name

    # Select the topic that matches the existing word using Tom-Select
    find("#change_group_new_word_attributes_topic + .ts-wrapper .ts-control").click
    find(".ts-dropdown .option", text: corrected_topic.name).click
    find(".ts-control input").send_keys(:escape)

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
