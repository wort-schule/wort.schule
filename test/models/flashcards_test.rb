# frozen_string_literal: true

require "test_helper"

class FlashcardsTest < ActiveSupport::TestCase
  setup do
    @learning_group = create(:learning_group)
    @list1 = create(:list)
    @list2 = create(:list)
    @user = create(:guest)
    @noun1 = create(:noun, name: "Adler")
    @noun2 = create(:noun, name: "Bauer")

    @list1.words << [@noun1, @noun2]
    @list2.words << [@noun1]
    @learning_group.lists << [@list1, @list2]
    LearningGroupMembership.create!(learning_group: @learning_group, user: @user, access: :granted)
  end

  test "adds the word only once" do
    assert_empty @user.first_flashcard_list.words

    Flashcards.add_list(@learning_group, @list1)
    assert_equal [@noun1, @noun2].sort, @user.first_flashcard_list.words.sort

    Flashcards.add_list(@learning_group, @list2)
    assert_equal [@noun1, @noun2].sort, @user.first_flashcard_list.words.sort
  end

  test "does not add the word when it is already in another flashcard section" do
    @user.flashcard_list(Flashcards::SECTIONS.second).words << @noun1
    assert_empty @user.first_flashcard_list.words
    assert_equal [@noun1], @user.flashcard_list(Flashcards::SECTIONS.second).words.to_a

    Flashcards.add_list(@learning_group, @list2)
    assert_empty @user.first_flashcard_list.words
    assert_equal [@noun1], @user.flashcard_list(Flashcards::SECTIONS.second).words.to_a

    Flashcards.add_list(@learning_group, @list1)
    assert_equal [@noun2], @user.first_flashcard_list.words.to_a
    assert_equal [@noun1], @user.flashcard_list(Flashcards::SECTIONS.second).words.to_a
  end

  test "removes a word from the first section" do
    assert_empty @user.first_flashcard_list.words

    Flashcards.add_list(@learning_group, @list1)
    Flashcards.add_list(@learning_group, @list2)
    assert_equal [@noun1, @noun2].sort, @user.first_flashcard_list.words.sort

    @list1.words.delete(@noun1)
    Flashcards.remove_word(@list1, @noun1)
    assert_equal [@noun1, @noun2].sort, @user.first_flashcard_list.words.sort

    @list2.words.delete(@noun1)
    Flashcards.remove_word(@list2, @noun1)
    assert_equal [@noun2], @user.first_flashcard_list.words.to_a
  end
end
