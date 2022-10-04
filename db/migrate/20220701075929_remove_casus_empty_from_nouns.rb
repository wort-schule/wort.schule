class RemoveCasusEmptyFromNouns < ActiveRecord::Migration[7.0]
  def change
    remove_column :nouns, :casus_empty, :integer
  end
end
