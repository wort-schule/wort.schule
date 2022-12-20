class WordTts < ActiveRecord::Migration[7.0]
  def change
    add_column :words, :with_tts, :boolean, default: true, null: false
  end
end
