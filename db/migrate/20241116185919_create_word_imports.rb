class CreateWordImports < ActiveRecord::Migration[7.1]
  def change
    create_table :word_imports do |t|
      t.string :name
      t.string :topic
      t.string :word_type
      t.string :state, null: false, default: :new

      t.timestamps
    end

    add_index :word_imports, [:name, :topic, :word_type]
  end
end
