class AddWordsToNewWords < ActiveRecord::Migration[7.1]
  def change
    add_reference :new_words, :duplicate_word, null: true, foreign_key: {to_table: :words}
    add_reference :new_words, :created_word, null: true, foreign_key: {to_table: :words}
  end
end
