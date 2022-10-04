class CreateLearningGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :learning_groups do |t|
      t.string :name
      t.references :teacher, null: false, foreign_key: {to_table: :users}
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
