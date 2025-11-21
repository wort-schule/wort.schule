class CreateKeywordEffectiveness < ActiveRecord::Migration[7.2]
  def change
    create_table :keyword_effectiveness, id: :uuid do |t|
      t.integer :word_id, null: false
      t.integer :keyword_id, null: false
      t.uuid :pick_id
      t.uuid :round_id
      t.integer :keyword_position
      t.datetime :revealed_at
      t.datetime :picked_at
      t.boolean :led_to_correct

      t.timestamps
    end

    add_index :keyword_effectiveness, [:word_id, :keyword_id]
    add_index :keyword_effectiveness, :keyword_id
    add_index :keyword_effectiveness, :pick_id
    add_index :keyword_effectiveness, :round_id
  end
end
