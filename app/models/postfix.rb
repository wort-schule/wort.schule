class Postfix < ApplicationRecord
  has_many :words
  validates_presence_of :name
end
