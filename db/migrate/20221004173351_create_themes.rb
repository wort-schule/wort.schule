class CreateThemes < ActiveRecord::Migration[7.0]
  def change
    create_table :themes do |t|
      t.string :name
      t.text :description
      t.text :template
      t.string :word_type, default: 'noun'
      t.string :visibility, default: 'private'
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :themes, :name, unique: true
  end
end
