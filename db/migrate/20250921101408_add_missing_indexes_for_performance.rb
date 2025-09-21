class AddMissingIndexesForPerformance < ActiveRecord::Migration[7.2]
  def change
    # Frequently queried foreign keys missing indexes
    add_index :compound_entities, :word_id unless index_exists?(:compound_entities, :word_id)
    add_index :compound_entities, :part_id unless index_exists?(:compound_entities, :part_id)
    add_index :compound_entities, [:part_type, :part_id] unless index_exists?(:compound_entities, [:part_type, :part_id])

    # Change group related indexes
    add_index :change_groups, :state unless index_exists?(:change_groups, :state)
    add_index :change_groups, :successor_id unless index_exists?(:change_groups, :successor_id)

    # Word attribute edits - frequently joined with change_groups
    add_index :word_attribute_edits, [:word_type, :word_id, :attribute_name], name: "idx_word_attr_edits_on_word_and_attr" unless index_exists?(:word_attribute_edits, [:word_type, :word_id, :attribute_name], name: "idx_word_attr_edits_on_word_and_attr")

    # Lists and words join table - missing both sides of the foreign key indexes
    add_index :lists_words, :list_id unless index_exists?(:lists_words, :list_id)
    add_index :lists_words, :word_id unless index_exists?(:lists_words, :word_id)
    # Note: Cannot add unique constraint due to existing duplicates. Add non-unique composite index instead
    add_index :lists_words, [:list_id, :word_id], name: "idx_lists_words_composite" unless index_exists?(:lists_words, [:list_id, :word_id], name: "idx_lists_words_composite")

    # Words table - frequently queried columns
    add_index :words, :name unless index_exists?(:words, :name)
    add_index :words, :type unless index_exists?(:words, :type)
    add_index :words, [:type, :name] unless index_exists?(:words, [:type, :name])
    add_index :words, :hit_counter unless index_exists?(:words, :hit_counter)

    # Compound words flag is frequently filtered
    add_index :words, :compound unless index_exists?(:words, :compound)

    # Word imports - frequently queried by state
    add_index :word_imports, :state unless index_exists?(:word_imports, :state)

    # Unlisted keywords - state is frequently filtered
    add_index :unlisted_keywords, :state unless index_exists?(:unlisted_keywords, :state)

    # Lists - frequently filtered by visibility and user
    add_index :lists, :visibility unless index_exists?(:lists, :visibility)
    add_index :lists, [:user_id, :visibility] unless index_exists?(:lists, [:user_id, :visibility])

    # Learning groups - frequently accessed by invitation token
    # Already has unique index on invitation_token

    # Reviews table - composite index for faster lookups
    add_index :reviews, [:reviewable_type, :reviewable_id, :state], name: "idx_reviews_on_reviewable_and_state" unless index_exists?(:reviews, [:reviewable_type, :reviewable_id, :state], name: "idx_reviews_on_reviewable_and_state")

    # Themes - frequently filtered by visibility and word_type
    add_index :themes, :visibility unless index_exists?(:themes, :visibility)
    add_index :themes, :word_type unless index_exists?(:themes, :word_type)
    add_index :themes, [:user_id, :visibility] unless index_exists?(:themes, [:user_id, :visibility])

    # Word view settings - frequently filtered by visibility
    add_index :word_view_settings, :visibility unless index_exists?(:word_view_settings, :visibility)
    add_index :word_view_settings, [:owner_id, :visibility] unless index_exists?(:word_view_settings, [:owner_id, :visibility])

    # Genus table - genus_keys array column for faster searches
    add_index :genus, :genus_keys, using: :gin unless index_exists?(:genus, :genus_keys)

    # Cologne phonetics on words for phonetic searches
    add_index :words, :cologne_phonetics, using: :gin unless index_exists?(:words, :cologne_phonetics)

    # Learning group memberships - composite index for role-based queries
    add_index :learning_group_memberships, :role unless index_exists?(:learning_group_memberships, :role)
    add_index :learning_group_memberships, [:user_id, :role] unless index_exists?(:learning_group_memberships, [:user_id, :role])
  end
end