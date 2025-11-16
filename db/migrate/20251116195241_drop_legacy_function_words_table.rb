class DropLegacyFunctionWordsTable < ActiveRecord::Migration[7.2]
  def change
    # Drop the legacy function_words table that was missed during the MTI to STI migration.
    # FunctionWord is now part of the words table using Single Table Inheritance.
    # This table was created in 20220524191629_create_data_model.rb and should have been
    # dropped in 20221104110839_change_mti_to_sti.rb but was accidentally omitted.
    drop_table :function_words do |t|
      t.integer "function_type"
    end
  end
end
