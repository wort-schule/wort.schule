class LearningGroupMembership < ApplicationRecord
  extend Enumerize

  belongs_to :learning_group
  belongs_to :student

  enumerize :access, in: %i[requested granted rejected], scope: true
end
