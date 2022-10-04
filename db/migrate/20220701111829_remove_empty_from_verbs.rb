class RemoveEmptyFromVerbs < ActiveRecord::Migration[7.0]
  def change
    remove_column :verbs, :present_empty, :integer
    remove_column :verbs, :past_empty, :integer
  end
end
