class RenameGenusToGenera < ActiveRecord::Migration[7.2]
  def change
    # Rename genus table to genera to follow Rails convention of plural table names.
    # Genus is the Latin word for "gender" in German grammar, and genera is its proper Latin plural.
    rename_table :genus, :genera
  end
end
