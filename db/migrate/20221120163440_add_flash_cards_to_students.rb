class AddFlashCardsToStudents < ActiveRecord::Migration[7.0]
  def up
    return unless defined? Student

    Student.find_each do |student|
      student.send(:setup_flashcards) if student.flashcard_lists.empty?
    end
  end

  def down
  end
end
