# frozen_string_literal: true

class Flashcards
  SECTIONS = (1..5).to_a

  def self.add_list(learning_group, list)
    learning_group.users.find_each do |user|
      list.words.each do |word|
        next if user.word_in_flashcards?(word)

        user.first_flashcard_list.words << word
      end
    end
  end

  def self.remove_word(list, word)
    list.learning_groups.find_each do |learning_group|
      remove_obsolete_words(learning_group)
    end
  end

  def self.remove_obsolete_words(learning_group)
    valid_word_ids = learning_group.lists.joins(:words).pluck("words.id")

    learning_group.users.find_each do |user|
      SECTIONS.each do |section|
        list = user.flashcard_list(section)

        obsolete_word_ids = list.words.pluck(:id) - valid_word_ids

        list.words.delete(Word.find(obsolete_word_ids)) if obsolete_word_ids.present?
      end
    end
  end

  def self.add_user(learning_group, user)
    learning_group.lists.each do |list|
      list.words.each do |word|
        next if user.word_in_flashcards?(word)

        user.first_flashcard_list.words << word
      end
    end
  end

  def self.remove_user(learning_group, user)
    remove_word_ids = learning_group.lists.joins(:words).pluck("words.id")
    word_ids_to_keep = user
      .learning_groups
      .reject { |group| group.id == learning_group.id }
      .map { |group| group.lists.joins(:words).pluck("words.id").uniq }
      .flatten
    word_ids_to_remove = remove_word_ids - word_ids_to_keep

    SECTIONS.each do |section|
      list = user.flashcard_list(section)

      obsolete_word_ids = list.words.pluck(:id) & word_ids_to_remove

      list.words.delete(Word.find(obsolete_word_ids)) if obsolete_word_ids.present?
    end
  end
end
