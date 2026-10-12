# frozen_string_literal: true

# The 2025 rename of compound_phonemreductions to compound_phonem_reductions
# also renamed the model to CompoundPhonemReduction, but left the old class
# name in the polymorphic compound_entities.part_type column. Rails turns that
# string back into a class when it loads CompoundEntity#part, so every word
# with such a part answered with HTTP 500 (issue #787).
class FixCompoundPhonemReductionPartType < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL)
      UPDATE compound_entities
      SET part_type = 'CompoundPhonemReduction'
      WHERE part_type = 'CompoundPhonemreduction'
    SQL
  end

  def down
    # Restoring the old spelling would break the word pages again.
  end
end
