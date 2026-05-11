class FixDoubleSerializedExampleSentences < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      UPDATE words
      SET example_sentences = (example_sentences #>> '{}')::jsonb
      WHERE jsonb_typeof(example_sentences) = 'string'
    SQL
  end

  def down
    # No rollback needed - data was incorrectly stored
  end
end
