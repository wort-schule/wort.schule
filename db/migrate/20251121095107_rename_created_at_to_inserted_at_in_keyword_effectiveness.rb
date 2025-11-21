class RenameCreatedAtToInsertedAtInKeywordEffectiveness < ActiveRecord::Migration[7.2]
  def change
    rename_column :keyword_effectiveness, :created_at, :inserted_at
  end
end
