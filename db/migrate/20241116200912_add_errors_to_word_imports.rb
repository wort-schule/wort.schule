class AddErrorsToWordImports < ActiveRecord::Migration[7.1]
  def change
    add_column :word_imports, :error, :text
  end
end
