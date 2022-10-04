class CreateLearningGroupMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :learning_group_memberships do |t|
      t.references :learning_group, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
