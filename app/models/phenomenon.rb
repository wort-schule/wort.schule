class Phenomenon < ApplicationRecord
  include Collectable

  has_and_belongs_to_many :words
  validates :name, presence: true
end
