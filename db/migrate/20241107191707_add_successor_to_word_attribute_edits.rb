class AddSuccessorToWordAttributeEdits < ActiveRecord::Migration[7.1]
  def change
    add_reference :word_attribute_edits, :successor, null: true, polymorphic: true
  end
end
