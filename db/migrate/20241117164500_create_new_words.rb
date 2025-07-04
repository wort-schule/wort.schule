class CreateNewWords < ActiveRecord::Migration[7.1]
  def change
    create_table :change_groups do |t|
      t.string :state, null: false, default: 'waiting_for_review'
      t.bigint :successor_id, null: true

      t.timestamps
    end

    create_table :new_words do |t|
      t.references :change_group, null: false, foreign_key: true
      t.string :name, null: false
      t.string :topic, null: false
      t.string :word_type, null: false
      t.string :llm_name
      t.string :llm_topic

      t.timestamps
    end

    add_index :new_words, [:name, :topic, :word_type]
  end
end
