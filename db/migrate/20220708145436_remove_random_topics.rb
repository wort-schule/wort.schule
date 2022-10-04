class RemoveRandomTopics < ActiveRecord::Migration[7.0]
  def up
    drop_table :random_topics
  end

  def down
    create_table :random_topics do |t|
      t.string "name"
      t.integer "score", default: 1

      t.timestamps
    end
  end
end
