class AddThemesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :theme_noun, null: true, foreign_key: {to_table: :themes}
    add_reference :users, :theme_verb, null: true, foreign_key: {to_table: :themes}
    add_reference :users, :theme_adjective, null: true, foreign_key: {to_table: :themes}
    add_reference :users, :theme_function_word, null: true, foreign_key: {to_table: :themes}
  end
end
