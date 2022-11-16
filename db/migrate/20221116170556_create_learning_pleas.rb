class CreateLearningPleas < ActiveRecord::Migration[7.0]
  def change
    create_table :learning_pleas do |t|
      t.references :learning_group, null: false, foreign_key: true
      t.references :list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
