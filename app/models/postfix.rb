class Postfix < ApplicationRecord
  include Collectable

  has_many :words
  validates_presence_of :name
end
