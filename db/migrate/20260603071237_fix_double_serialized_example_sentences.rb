# frozen_string_literal: true

# Some word rows stored their example_sentences JSONB column double-serialized:
# the JSON *string* "[]" (or "[\"a\", \"b\"]") instead of the JSON *array*
# [] / ["a", "b"]. That made Word#example_sentences read back a String and
# crashed every word detail page (issue #751).
#
# Unwrap the inner JSON text (#>> '{}') and re-cast it to jsonb so the column
# holds a real array again. We only touch rows whose value is a JSON string
# that looks like an array; anything else is left untouched and handled
# defensively by the model reader.
class FixDoubleSerializedExampleSentences < ActiveRecord::Migration[8.1]
  def up
    execute(<<~'SQL')
      UPDATE words
      SET example_sentences = (example_sentences #>> '{}')::jsonb
      WHERE jsonb_typeof(example_sentences) = 'string'
        AND (example_sentences #>> '{}') ~ '^\s*\['
    SQL
  end

  def down
    # Re-corrupting the data would serve no purpose, so there is nothing to undo.
  end
end
