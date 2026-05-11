class CreateBulkEdits < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_edits do |t|
      t.references :user, null: false, foreign_key: true
      t.string :operation, null: false
      t.string :field, null: false
      t.jsonb :word_ids, null: false, default: []
      t.jsonb :assigned_values, null: false, default: []
      t.jsonb :previous_values, null: false, default: {}
      t.string :search_query
      t.boolean :undone, default: false
      t.datetime :undone_at
      t.timestamps
    end
  end
end
