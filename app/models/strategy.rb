class Strategy < ApplicationRecord
  has_and_belongs_to_many :words
  validates_presence_of :name
end
