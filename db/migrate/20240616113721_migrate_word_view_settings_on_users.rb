class MigrateWordViewSettingsOnUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :word_view_setting, null: true, foreign_key: true
    remove_reference :users, :theme_noun, null: true, foreign_key: {to_table: :themes}
    remove_reference :users, :theme_verb, null: true, foreign_key: {to_table: :themes}
    remove_reference :users, :theme_adjective, null: true, foreign_key: {to_table: :themes}
    remove_reference :users, :theme_function_word, null: true, foreign_key: {to_table: :themes}
  end
end
