class LearningGroupMembership < ApplicationRecord
  extend Enumerize

  belongs_to :learning_group
  belongs_to :user

  enumerize :access, in: %i[requested invited granted rejected], scope: true
  enumerize :role, in: %i[member group_admin], scope: true

  validates :user, uniqueness: {scope: :learning_group_id}
end
