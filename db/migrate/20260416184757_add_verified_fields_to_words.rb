class AddVerifiedFieldsToWords < ActiveRecord::Migration[7.2]
  def change
    add_column :words, :example_sentences_verified, :boolean, default: false, null: false
    add_column :words, :syllables_verified, :boolean, default: false, null: false
  end
end
