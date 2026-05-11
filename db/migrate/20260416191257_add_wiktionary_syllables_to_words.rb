class AddWiktionarySyllablesToWords < ActiveRecord::Migration[7.2]
  def change
    add_column :words, :wiktionary_syllables, :string
  end
end
