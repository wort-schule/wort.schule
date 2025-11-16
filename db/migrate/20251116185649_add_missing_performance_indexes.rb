class AddMissingPerformanceIndexes < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    # Functional index for case-insensitive word name lookups
    # This improves performance for queries like: Word.where("name ILIKE ?", search_term)
    add_index :words, "LOWER(name)",
              name: "idx_words_lower_name",
              algorithm: :concurrently
  end
end
