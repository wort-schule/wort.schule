class CompoundInterfix < ApplicationRecord
  has_one :compound_entity, as: :part
  has_many :words, through: :compound_entity

  validates_presence_of :name
end
