class CreateWordAttributeEdits < ActiveRecord::Migration[7.1]
  def change
    create_table :word_attribute_edits do |t|
      t.references :word, null: false, polymorphic: true
      t.string :attribute_name, null: false
      t.string :value
      t.string :state, null: false, default: 'waiting_for_review'

      t.timestamps
    end
  end
end
