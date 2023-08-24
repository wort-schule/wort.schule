class ChangeColognePhoneticsToArray < ActiveRecord::Migration[7.0]
  def up
    remove_column :words, :cologne_phonetics
    add_column :words, :cologne_phonetics, :string, array: true, default: []

    Word.find_each do |word|
      word.send(:update_cologne_phonetics)
      word.save(validate: false)
    end
  end

  def down
    Word.find_each do |word|
      word.update_column(:cologne_phonetics, ColognePhonetics.encode(word.name))
    end
  end
end
