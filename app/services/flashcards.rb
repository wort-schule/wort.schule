# frozen_string_literal: true

class Flashcards
  SECTIONS = (1..5).to_a

  def self.add_list(learning_group, list)
    learning_group.students.find_each do |student|
      list.words.each do |word|
        next if student.word_in_flashcards?(word)

        student.first_flashcard_list.words << word
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

    learning_group.students.find_each do |student|
      SECTIONS.each do |section|
        list = student.flashcard_list(section)

        obsolete_word_ids = list.words.pluck(:id) - valid_word_ids

        list.words.delete(Word.find(obsolete_word_ids)) if obsolete_word_ids.present?
      end
    end
  end
end
