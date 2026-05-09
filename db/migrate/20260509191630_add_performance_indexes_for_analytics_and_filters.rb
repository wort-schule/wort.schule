class AddPerformanceIndexesForAnalyticsAndFilters < ActiveRecord::Migration[8.1]
  def change
    # KeywordAnalyticsController scans the full keyword_effectiveness table
    # for `inserted_at >= ?` ranges and for `led_to_correct = true AND
    # keyword_position = N` aggregations. As the table grows (one row per
    # keyword shown per pick) both become sequential scans.
    add_index :keyword_effectiveness, :inserted_at
    add_index :keyword_effectiveness, [:led_to_correct, :keyword_position]

    # WordFilter#filter_consonant_vowel runs `where(consonant_vowel: ...)`
    # with no covering index — every advanced search seq-scans words.
    add_index :words, :consonant_vowel

    # `hierarchy.words.ordered_lexigraphically` sorts by name within a
    # hierarchy. Pairing hierarchy_id with name lets Postgres satisfy the
    # ORDER BY from the index, mirroring the existing
    # index_words_on_type_and_name pattern.
    add_index :words, [:hierarchy_id, :name]
  end
end
