class AddWordingToWordViewSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :word_view_settings, :word_type_wording, :string, null: false, default: 'default'
    add_column :word_view_settings, :genus_wording, :string, null: false, default: 'default'
    add_column :genus, :genus_keys, :string, array: true, default: []

    reversible do |direction|
      direction.up do
        # Use raw SQL to avoid dependency on Genus model's table_name setting
        # which may reference "genera" before the rename migration runs
        table = ActiveRecord::Base.connection.table_exists?(:genera) ? :genera : :genus
        records = execute("SELECT id, name FROM #{table}")
        records.each do |record|
          keys = []
          keys << "masculinum" if record["name"]&.include?("Maskulinum")
          keys << "femininum" if record["name"]&.include?("Femininum")
          keys << "neutrum" if record["name"]&.include?("Neutrum")
          execute("UPDATE #{table} SET genus_keys = '{#{keys.join(",")}}' WHERE id = #{record["id"]}")
        end
      end
    end
  end
end
