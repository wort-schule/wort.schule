# frozen_string_literal: true

# compound_entities had no foreign key on words, so deleting a word left its
# compound parts behind as rows nobody can reach (issue #787). Remove those
# leftovers first, because Postgres refuses to add a foreign key while rows
# still point at a missing word.
class AddWordForeignKeyToCompoundEntities < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL)
      DELETE FROM compound_entities
      WHERE NOT EXISTS (
        SELECT 1 FROM words WHERE words.id = compound_entities.word_id
      )
    SQL

    add_foreign_key :compound_entities, :words, on_delete: :cascade
  end

  def down
    remove_foreign_key :compound_entities, :words
  end
end
