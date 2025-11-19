class CreateGlobalSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :global_settings do |t|
      t.string :key, null: false
      t.integer :integer_value
      t.boolean :boolean_value
      t.text :string_value
    end

    add_index :global_settings, :key, unique: true

    # Insert default value for reviews_required
    execute "INSERT INTO global_settings (key, integer_value) VALUES ('reviews_required', 1)"
  end
end
