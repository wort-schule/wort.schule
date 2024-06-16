class AddWordingToWordViewSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :word_view_settings, :word_type_wording, :string, null: false, default: 'default'
    add_column :word_view_settings, :genus_wording, :string, null: false, default: 'default'
    add_column :genus, :genus_keys, :string, array: true, default: []

    reversible do |direction|
      direction.up do
        Genus.find_each do |genus|
          genus.genus_keys << :masculinum if genus.name.include?('Maskulinum')
          genus.genus_keys << :femininum if genus.name.include?('Femininum')
          genus.genus_keys << :neutrum if genus.name.include?('Neutrum')
          genus.save!
        end
      end
    end
  end
end
