class RenameCompoundPhonemreductionsToCompoundPhonemReductions < ActiveRecord::Migration[7.2]
  def change
    # Fix typo in table name: compound_phonemreductions → compound_phonem_reductions
    # The 'R' in 'Reduction' should be capitalized in the model name CompoundPhonemReduction.
    # Rails convention converts this to compound_phonem_reductions (with underscore before capital letters).
    rename_table :compound_phonemreductions, :compound_phonem_reductions
  end
end
