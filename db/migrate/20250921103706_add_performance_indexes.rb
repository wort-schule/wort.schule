class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    # Compound index for frequently filtered words
    add_index :words, [:type, :name, :hit_counter],
              name: "idx_words_type_name_hit_counter",
              algorithm: :concurrently

    # Index for learning group memberships queries
    add_index :learning_group_memberships, [:access, :role, :learning_group_id],
              name: "idx_learning_group_memberships_access_role",
              algorithm: :concurrently

    # Index for user flashcard lookups
    add_index :lists, [:user_id, :flashcard_section],
              name: "idx_users_flashcard_section",
              where: "flashcard_section IS NOT NULL",
              algorithm: :concurrently

    # Composite index for word filtering
    add_index :words, [:foreign, :prototype, :compound, :type],
              name: "idx_words_foreign_prototype_compound",
              algorithm: :concurrently

    # For compound entity lookups
    add_index :compound_entities, [:word_id, :pos],
              name: "idx_compound_entities_word_pos",
              algorithm: :concurrently

    # For active storage attachment queries
    add_index :active_storage_attachments, [:record_type, :record_id, :name],
              name: "idx_active_storage_attachments_record_name",
              algorithm: :concurrently

    # For word view settings lookup
    add_index :word_view_settings, [:owner_id, :visibility],
              name: "idx_word_view_settings_owner_visibility",
              algorithm: :concurrently
  end
end