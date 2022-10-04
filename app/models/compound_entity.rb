class CompoundEntity < ApplicationRecord
  default_scope { order(pos: :asc) }

  VALID_COMPOUND_TYPES = %w[
    CompoundPreconfix
    CompoundInterfix
    CompoundPostconfix
    CompoundPhonemreduction
    CompoundVocalalternation
    Word
  ]

  belongs_to :word
  belongs_to :part, polymorphic: true

  def to_s
    part.name
  end
end
