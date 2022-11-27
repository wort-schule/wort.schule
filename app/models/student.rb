# frozen_string_literal: true

class Student < User
  self.table_name = :users
  self.inheritance_column = :role

  has_many :learning_group_memberships, dependent: :destroy
  has_many :learning_groups, through: :learning_group_memberships
  has_many :flashcard_lists, -> { where.not(flashcard_section: nil).order(:flashcard_section) }, class_name: "List", foreign_key: :user_id

  after_create :setup_flashcards

  def first_flashcard_list
    flashcard_list(Flashcards::SECTIONS.first)
  end

  def flashcard_list(flashcard_section)
    flashcard_lists.find_by(flashcard_section:)
  end

  def word_in_flashcards?(word)
    flashcard_lists.joins(:words).exists?("words.id": word.id)
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
