class RemoveThemesFromLearningGroups < ActiveRecord::Migration[7.1]
  def change
    remove_reference :learning_groups, :theme_noun, null: true, foreign_key: {to_table: :themes}
    remove_reference :learning_groups, :theme_verb, null: true, foreign_key: {to_table: :themes}
    remove_reference :learning_groups, :theme_adjective, null: true, foreign_key: {to_table: :themes}
    remove_reference :learning_groups, :theme_function_word, null: true, foreign_key: {to_table: :themes}
    remove_column :learning_groups, :font, :string
  end
end
