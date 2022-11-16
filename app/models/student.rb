# frozen_string_literal: true

class Student < User
  self.table_name = :users
  self.inheritance_column = :role

  has_many :learning_group_memberships, dependent: :destroy
  has_many :learning_groups, through: :learning_group_memberships

  after_create :setup_flashcards

  def flashcard_list(flashcard_section)
    lists.find_by(flashcard_section:)
  end

  private

  def setup_flashcards
    Flashcards::SECTIONS.each do |section|
      List.create!(
        user: self,
        flashcard_section: section,
        visibility: :private
      )
    end
  end
end
