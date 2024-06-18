class CreateWordViewSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :word_view_settings do |t|
      t.string :name, null: false
      t.string :font
      t.string :visibility, default: "private"
      t.references :owner, null: false, foreign_key: {to_table: :users}
      t.references :theme_noun, null: true, foreign_key: {to_table: :themes}
      t.references :theme_verb, null: true, foreign_key: {to_table: :themes}
      t.references :theme_adjective, null: true, foreign_key: {to_table: :themes}
      t.references :theme_function_word, null: true, foreign_key: {to_table: :themes}

      t.timestamps
    end
  end
end
