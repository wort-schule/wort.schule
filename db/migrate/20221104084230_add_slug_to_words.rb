class AddSlugToWords < ActiveRecord::Migration[7.0]
  def change
    add_column :words, :slug, :string
    add_index :words, :slug, unique: true

    # Generate slugs for existing models
    reversible do |change|
      change.up do
        Word.find_each(&:save)
      end
    end
  end
end
