# frozen_string_literal: true

class Flashcards
  SECTIONS = (1..5).to_a

  def self.add_list(learning_group, list)
    learning_group.students.each do |student|
      list.words.each do |word|
        next if student.word_in_flashcards?(word)

        student.first_flashcard_list.words << word
      end
    end
  end
end
