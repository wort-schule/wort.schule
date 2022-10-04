class AddAllDataFromOldApp < ActiveRecord::Migration[7.0]
  def up
    insert_query = File.read(Rails.root.join('db/seeds/wordapp_dump_2021-10-25.sql'))

    execute insert_query
  end

  def down
  end
end
