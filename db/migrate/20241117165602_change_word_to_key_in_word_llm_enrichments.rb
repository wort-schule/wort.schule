class ChangeWordToKeyInWordLlmEnrichments < ActiveRecord::Migration[7.1]
  def change
    add_column :word_llm_invocations, :key, :string, null: true
    execute "UPDATE word_llm_invocations SET key = concat(word_type, '#', word_id)" unless reverting?
    change_column_null :word_llm_invocations, :key, false
    remove_reference :word_llm_invocations, :word, polymorphic: true
  end
end
