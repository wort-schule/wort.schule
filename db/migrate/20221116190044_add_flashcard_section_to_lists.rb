class AddFlashcardSectionToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :flashcard_section, :integer, null: true
  end
end
