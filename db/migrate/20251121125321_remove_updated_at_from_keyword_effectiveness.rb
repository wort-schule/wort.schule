class RemoveUpdatedAtFromKeywordEffectiveness < ActiveRecord::Migration[7.2]
  def change
    remove_column :keyword_effectiveness, :updated_at, :datetime
  end
end
