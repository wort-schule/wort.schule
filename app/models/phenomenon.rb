class Phenomenon < ApplicationRecord
  include Collectable

  has_and_belongs_to_many :words
  validates_presence_of :name
end
