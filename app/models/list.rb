class List < ApplicationRecord
  extend Enumerize

  belongs_to :user
  has_and_belongs_to_many :words

  enumerize :visibility, in: %i[private public], default: :private

  scope :of_user, ->(user) { where(user:) }

  validates :name, presence: true
end
