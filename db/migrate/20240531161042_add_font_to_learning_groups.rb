class AddFontToLearningGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :learning_groups, :font, :string
  end
end
