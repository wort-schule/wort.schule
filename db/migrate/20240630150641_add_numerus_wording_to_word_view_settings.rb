class AddNumerusWordingToWordViewSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :word_view_settings, :numerus_wording, :string, null: false, default: "default"
  end
end
