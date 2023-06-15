class LearningGroupMembership < ApplicationRecord
  extend Enumerize

  belongs_to :learning_group
  belongs_to :user

  enumerize :access, in: %i[requested invited granted rejected], scope: true, predicates: true
  enumerize :role, in: %i[member group_admin], scope: true

  validates :user, uniqueness: {scope: :learning_group_id}

  after_destroy :remove_words

  private

  def remove_words
    Flashcards.remove_user(learning_group, user)
  end
end
