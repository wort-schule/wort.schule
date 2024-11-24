class AddIndexToWordLlmInvocations < ActiveRecord::Migration[7.1]
  def change
    add_index :word_llm_invocations, :key
  end
end
