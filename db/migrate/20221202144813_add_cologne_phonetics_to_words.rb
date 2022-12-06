class AddColognePhoneticsToWords < ActiveRecord::Migration[7.0]
  def change
    add_column :words, :cologne_phonetics, :string
    add_index :words, :cologne_phonetics

    reversible do |change|
      change.up do
        Word.find_each do |word|
          word.update_attribute(:cologne_phonetics, ColognePhonetics.encode(word.name))
        end
      end
    end
  end
end
