# frozen_string_literal: true

require "application_system_test_case"

class ReviewsSingleReviewerNewWordTest < ApplicationSystemTestCase
  setup do
    @admin = create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    GlobalSetting.reviews_required = 1
  end

  test "creates the word immediately when a single reviewer confirms" do
    create(:topic, name: "Tiere")
    new_word = create(:new_word, name: "TestWort", topic: "Tiere", word_type: "Noun")

    assert_equal "waiting_for_review", new_word.change_group.state
    assert_nil Word.find_by(name: "TestWort")

    login_as @admin
    visit reviews_path

    assert_text "TestWort"

    click_button I18n.t("reviews.new_word_component.create")

    new_word.reload
    assert_equal "created", new_word.change_group.state
    assert_equal 1, new_word.change_group.reviews.count
    assert_equal "created", new_word.change_group.reviews.first.state

    created_word = Word.find_by(name: "TestWort")
    assert created_word.present?
    assert_equal "Noun", created_word.type
    assert_equal "Tiere", created_word.topics.first.name
    assert_equal created_word, new_word.created_word

    assert_match(%r{^/seite/reviews(/\d+)?$}, current_path)
  end

  test "does not require a second review when reviews_required is 1" do
    create(:topic, name: "Natur")
    new_word = create(:new_word, name: "EinzigesWort", topic: "Natur", word_type: "Noun")

    login_as @admin
    visit reviews_path

    click_button I18n.t("reviews.new_word_component.create")

    created_word = Word.find_by(name: "EinzigesWort")
    assert created_word.present?

    new_word.reload
    assert_equal "created", new_word.change_group.state
  end
end
