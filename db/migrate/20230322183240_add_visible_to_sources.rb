class AddVisibleToSources < ActiveRecord::Migration[7.0]
  def change
    add_column :sources, :visible, :boolean, null: false, default: true
  end
end
