class CreateBulkEditsAndChanges < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_edits do |t|
      t.references :user, null: false, foreign_key: {on_delete: :restrict}
      t.string :operation, null: false
      t.string :field, null: false
      t.jsonb :intent_value, null: false
      t.string :search_query
      t.string :missing_field
      t.integer :affected_count, null: false, default: 0
      t.datetime :undone_at
      t.timestamps
    end

    add_index :bulk_edits, [:user_id, :created_at]
    add_index :bulk_edits, :undone_at

    create_table :bulk_edit_changes do |t|
      t.references :bulk_edit, null: false, foreign_key: true
      t.references :word, foreign_key: {on_delete: :nullify}
      t.jsonb :previous_value, null: false
      t.jsonb :applied_value, null: false
      t.datetime :reverted_at
      t.timestamps
    end

    add_index :bulk_edit_changes, [:bulk_edit_id, :word_id], unique: true
    add_index :bulk_edit_changes, :reverted_at
  end
end
