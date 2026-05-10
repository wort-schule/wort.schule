# frozen_string_literal: true

require "test_helper"

class UserPerformanceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @word = create(:noun)
    @list = create(:list, user: @user, flashcard_section: "section1")
    @list.words << @word
  end

  test "#word_in_flashcards? returns true for words in flashcards" do
    assert_equal true, @user.word_in_flashcards?(@word)
  end

  test "#word_in_flashcards? returns false for words not in flashcards" do
    other_word = create(:noun)
    assert_equal false, @user.word_in_flashcards?(other_word)
  end
end
