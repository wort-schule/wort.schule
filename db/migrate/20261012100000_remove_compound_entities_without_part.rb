# frozen_string_literal: true

# Deleting a compound part (an interfix, or a word used inside another word)
# used to leave its compound_entities rows behind. Such a row has no part to
# show, so the page of the word it belongs to crashed (follow-up to #787).
# The models now refuse to delete a part that is in use; this removes the
# rows left over from before.
class RemoveCompoundEntitiesWithoutPart < ActiveRecord::Migration[8.1]
  # part_type is polymorphic, so the database cannot guard it with a foreign
  # key and every table a part can live in is checked by hand.
  PART_TABLES = {
    "Word" => "words",
    "CompoundInterfix" => "compound_interfixes",
    "CompoundPreconfix" => "compound_preconfixes",
    "CompoundPostconfix" => "compound_postconfixes",
    "CompoundPhonemReduction" => "compound_phonem_reductions",
    "CompoundVocalalternation" => "compound_vocalalternations"
  }.freeze

  def up
    PART_TABLES.each do |part_type, table|
      execute(<<~SQL)
        DELETE FROM compound_entities
        WHERE part_type = #{connection.quote(part_type)}
          AND NOT EXISTS (
            SELECT 1 FROM #{connection.quote_table_name(table)} parts
            WHERE parts.id = compound_entities.part_id
          )
      SQL
    end
  end

  def down
    # The deleted rows pointed at nothing, so there is nothing to restore.
  end
end
