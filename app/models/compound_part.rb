# frozen_string_literal: true

# Base class for compound word parts (Interfix, Phonemreduction, Postconfix, Preconfix, Vocalalternation).
# Provides common associations and validations for all compound part types.
class CompoundPart < ApplicationRecord
  self.abstract_class = true

  has_one :compound_entity, as: :part
  has_many :words, through: :compound_entity

  validates_presence_of :name
end
