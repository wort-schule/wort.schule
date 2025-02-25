class CreateUnlistedKeywords < ActiveRecord::Migration[7.2]
  def change
    create_table :unlisted_keywords do |t|
      t.references :word, null: false, polymorphic: true
      t.references :word_import, null: false, foreign_key: true
      t.references :new_word, null: true, foreign_key: true
      t.string :state, null: false, default: 'new'

      t.timestamps
    end
  end
end
