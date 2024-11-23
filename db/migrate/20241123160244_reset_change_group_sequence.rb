class ResetChangeGroupSequence < ActiveRecord::Migration[7.1]
  def up
    execute "SELECT setval('change_groups_id_seq', (SELECT MAX(id) FROM change_groups));"
  end

  def down
  end
end
