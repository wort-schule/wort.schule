class LearningGroup < ApplicationRecord
  default_scope { order(:name) }

  belongs_to :teacher
  belongs_to :school

  has_many :learning_group_memberships, dependent: :destroy
  has_many :granted_learning_group_memberships, -> { with_access("granted") }, class_name: "LearningGroupMembership"
  has_many :students, through: :granted_learning_group_memberships

  has_secure_token :invitation_token, length: 42

  validates_presence_of :name
end
