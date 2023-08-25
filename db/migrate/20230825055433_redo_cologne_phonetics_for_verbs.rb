class RedoColognePhoneticsForVerbs < ActiveRecord::Migration[7.0]
  def up
    Word.find_each do |word|
      word.send(:update_cologne_phonetics)
      word.save(validate: false)
    end
  end

  def down
  end
end
