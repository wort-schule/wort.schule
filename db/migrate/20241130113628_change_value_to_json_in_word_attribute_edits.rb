class ChangeValueToJsonInWordAttributeEdits < ActiveRecord::Migration[7.1]
  def up
    execute "UPDATE word_attribute_edits SET value = CONCAT('\"', value, '\"')"
  end

  def down
  end
end
