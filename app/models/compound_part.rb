# frozen_string_literal: true

# Base class for compound word parts (Interfix, Phonemreduction, Postconfix, Preconfix, Vocalalternation).
# Provides common associations and validations for all compound part types.
class CompoundPart < ApplicationRecord
  self.abstract_class = true

  # A part that is still used in a word cannot be deleted, otherwise that word
  # would silently lose a part.
  has_many :compound_usages, class_name: "CompoundEntity", as: :part, dependent: :restrict_with_error
  has_many :words, through: :compound_usages

  validates :name, presence: true
end
