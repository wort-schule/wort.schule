class List < ApplicationRecord
  extend Enumerize

  belongs_to :user
  has_and_belongs_to_many :words
  has_many :learning_pleas
  has_many :learning_groups, through: :learning_pleas

  enumerize :visibility, in: %i[private public], default: :private

  scope :of_user, ->(user) { where(user:) }

  validates :name, presence: true

  def to_s
    name
  end
end
