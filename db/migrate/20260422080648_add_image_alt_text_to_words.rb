class AddImageAltTextToWords < ActiveRecord::Migration[7.2]
  def change
    add_column :words, :image_alt_text, :string
  end
end
