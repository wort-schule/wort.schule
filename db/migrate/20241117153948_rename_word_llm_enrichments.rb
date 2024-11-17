class RenameWordLlmEnrichments < ActiveRecord::Migration[7.1]
  def change
    rename_table :word_llm_enrichments, :word_llm_invocations

    add_column :word_llm_invocations, :invocation_type, :string, null: true
    execute "UPDATE word_llm_invocations SET invocation_type = 'enrichment'" unless reverting?
    change_column_null :word_llm_invocations, :invocation_type, false
    add_index :word_llm_invocations, :invocation_type
  end
end
