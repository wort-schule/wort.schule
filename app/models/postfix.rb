class Postfix < ApplicationRecord
  include Collectable

  has_many :words
  validates :name, presence: true
end
