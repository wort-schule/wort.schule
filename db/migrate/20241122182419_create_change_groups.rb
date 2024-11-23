class CreateChangeGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :change_groups do |t|
      t.string :state, null: false, default: 'waiting_for_review'
      t.bigint :successor_id, null: true

      t.timestamps
    end

    execute <<~SQL
      INSERT INTO change_groups (id, state, successor_id, created_at, updated_at)
      SELECT id, state, successor_id, created_at, updated_at
      FROM word_attribute_edits
    SQL

    add_foreign_key :change_groups, :change_groups, column: :successor_id

    drop_view :reviewers

    remove_reference :word_attribute_edits, :successor, polymorphic: true
    remove_column :word_attribute_edits, :state, null: false, default: 'waiting_for_review'

    add_reference :word_attribute_edits, :change_group, null: true
    execute "UPDATE word_attribute_edits SET change_group_id = id"
    change_column_null :word_attribute_edits, :change_group_id, false

    execute <<~SQL
      UPDATE reviews SET reviewable_type = 'ChangeGroup'
    SQL

    create_view :reviewers, version: 2
  end
end
