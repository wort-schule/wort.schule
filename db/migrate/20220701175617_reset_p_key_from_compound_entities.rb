class ResetPKeyFromCompoundEntities < ActiveRecord::Migration[7.0]
  def up
    ActiveRecord::Base.connection.reset_pk_sequence!('compound_entities')
  end

  def down
  end
end
