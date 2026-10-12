class CompoundEntity < ApplicationRecord
  default_scope { order(pos: :asc) }

  VALID_COMPOUND_TYPES = %w[
    CompoundPreconfix
    CompoundInterfix
    CompoundPostconfix
    CompoundPhonemReduction
    CompoundVocalalternation
    Word
  ]

  belongs_to :word
  belongs_to :part, polymorphic: true

  validates :part_type, inclusion: {in: VALID_COMPOUND_TYPES}

  delegate :name, to: :word

  def to_s
    part&.name.to_s
  end
end
