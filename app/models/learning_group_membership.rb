class LearningGroupMembership < ApplicationRecord
  extend Enumerize

  belongs_to :learning_group
  belongs_to :user

  enumerize :access, in: %i[requested granted rejected], scope: true
  enumerize :role, in: %i[member group_admin], scope: true
end
