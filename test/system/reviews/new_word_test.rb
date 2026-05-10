# frozen_string_literal: true

require "application_system_test_case"

class ReviewsNewWordTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @me = create(:admin)
  end

  test "chooses a duplicate word" do
    new_word = create(:new_word)
    duplicate_word = create(:noun, name: new_word.llm_name)

    login_as @me
    visit reviews_path
    assert_text new_word.name
    assert_text new_word.topic

    assert_difference -> { Review.count }, +1 do
      assert_no_difference -> { Word.count } do
        click_on I18n.t("reviews.duplicate_words_component.choose")
      end
    end

    new_word.reload
    assert_equal duplicate_word, new_word.duplicate_word
    assert_nil new_word.created_word
  end

  test "skips the review" do
    new_word = create(:new_word)

    login_as @me
    visit reviews_path
    assert_text new_word.name
    assert_text new_word.topic

    assert_difference -> { Review.count }, +1 do
      assert_no_difference -> { Word.count } do
        click_on I18n.t("reviews.show.actions.skip")
      end
    end

    assert_equal "skipped", Review.last.state
  end

  test "discards the review" do
    with_environment("REVIEW_EXCEPTION_MAIL" => "muster@example.com") do
      new_word = create(:new_word)

      login_as @me
      visit reviews_path
      assert_text new_word.name
      assert_text new_word.topic

      assert_difference -> { Review.count }, +1 do
        assert_no_difference -> { Word.count } do
          assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
            click_on I18n.t("reviews.show.actions.discard")
          end
        end
      end

      assert_equal "discarded", Review.last.state
    end
  end

  test "confirms the new word" do
    topic = create(:topic, name: "Tiere")
    new_word = create(:new_word, topic: topic.name)

    login_as @me
    visit reviews_path
    assert_text new_word.name

    assert_difference -> { Review.count }, +1 do
      assert_difference -> { Word.count }, +1 do
        assert_enqueued_with(job: EnrichWordJob) do
          click_on I18n.t("reviews.new_word_component.create")
        end
      end
    end

    created_word = Word.last
    assert_equal new_word.name, created_word.name
    assert_equal [new_word.topic], created_word.topics.map(&:name)

    new_word.reload
    assert_nil new_word.duplicate_word
    assert_equal created_word, new_word.created_word
  end

  test "changes and creates the new word" do
    create(:topic, name: "Tiere")
    corrected_topic = create(:topic, name: "Lebewesen")
    new_word = create(:new_word, topic: "Tiere")
    corrected_name = "Kater"

    login_as @me
    visit reviews_path
    assert_text new_word.name

    fill_in NewWord.human_attribute_name(:name), with: corrected_name

    find("#change_group_new_word_attributes_topic + .ts-wrapper .ts-control").click
    find(".ts-dropdown .option", text: corrected_topic.name).click
    find(".ts-control input").send_keys(:escape)

    assert_difference -> { Review.count }, +1 do
      assert_difference -> { Word.count }, +1 do
        click_on I18n.t("reviews.new_word_component.create")
      end
    end

    created_word = Word.last
    assert_equal corrected_name, created_word.name
    assert_equal [corrected_topic.name], created_word.topics.map(&:name)

    new_word.reload
    assert_nil new_word.duplicate_word
    assert_equal created_word, new_word.created_word
  end

  test "shows topic as Tom-Select with existing topics" do
    create(:topic, name: "Tiere")
    create(:topic, name: "Pflanzen")
    new_word = create(:new_word, topic: "")

    login_as @me
    visit review_path(new_word.change_group)

    find("#change_group_new_word_attributes_topic + .ts-wrapper .ts-control").click

    assert_css ".ts-dropdown .option", text: "Tiere"
    assert_css ".ts-dropdown .option", text: "Pflanzen"
  end

  test "creates a new word with empty topic field initially" do
    new_word = create(:new_word, topic: "")
    existing_topic = create(:topic, name: "Tiere")

    login_as @me
    visit review_path(new_word.change_group)
    assert_text new_word.name

    fill_in NewWord.human_attribute_name(:name), with: "Hund"

    find("#change_group_new_word_attributes_topic + .ts-wrapper .ts-control").click
    find(".ts-dropdown .option", text: existing_topic.name).click

    assert_difference -> { Review.count }, +1 do
      assert_difference -> { Word.count }, +1 do
        click_on I18n.t("reviews.new_word_component.create")
      end
    end

    created_word = Word.last
    assert_equal "Hund", created_word.name
    assert_equal [existing_topic.name], created_word.topics.map(&:name)
  end

  test "does not create a new word if that word already exists" do
    create(:topic, name: "Tiere")
    corrected_topic = create(:topic, name: "Lebewesen")
    new_word = create(:new_word, topic: "Tiere")
    corrected_name = "Kater"
    existing_word = create(:noun, name: corrected_name, topics: [corrected_topic])

    login_as @me
    visit reviews_path
    assert_text new_word.name

    fill_in NewWord.human_attribute_name(:name), with: corrected_name

    find("#change_group_new_word_attributes_topic + .ts-wrapper .ts-control").click
    find(".ts-dropdown .option", text: corrected_topic.name).click
    find(".ts-control input").send_keys(:escape)

    assert_difference -> { Review.count }, +1 do
      assert_no_difference -> { Word.count } do
        click_on I18n.t("reviews.new_word_component.create")
      end
    end

    assert_equal "duplicate", Review.last.state

    new_word.reload
    assert_equal existing_word, new_word.duplicate_word
    assert_nil new_word.created_word
  end
end
