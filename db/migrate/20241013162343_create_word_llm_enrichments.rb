class CreateWordLlmEnrichments < ActiveRecord::Migration[7.1]
  def change
    create_table :word_llm_enrichments do |t|
      t.references :word, null: false, index: true, polymorphic: true
      t.string :state, index: true, null: false, default: 'new'
      t.text :error
      t.datetime :completed_at

      t.timestamps
    end
  end
end
