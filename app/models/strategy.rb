class Strategy < ApplicationRecord
  include Collectable

  has_and_belongs_to_many :words
  validates :name, presence: true

  has_one_attached :fresch_symbol
end
