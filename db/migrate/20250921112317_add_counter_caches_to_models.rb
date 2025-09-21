class AddCounterCachesToModels < ActiveRecord::Migration[7.2]
  def change
    # Add counter caches for better performance
    add_column :topics, :words_count, :integer, default: 0, null: false
    add_column :sources, :words_count, :integer, default: 0, null: false
    add_column :hierarchies, :words_count, :integer, default: 0, null: false

    # Populate existing counts
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE topics
          SET words_count = (
            SELECT COUNT(*)
            FROM topics_words
            WHERE topics_words.topic_id = topics.id
          )
        SQL

        execute <<~SQL
          UPDATE sources
          SET words_count = (
            SELECT COUNT(*)
            FROM sources_words
            WHERE sources_words.source_id = sources.id
          )
        SQL

        execute <<~SQL
          UPDATE hierarchies
          SET words_count = (
            SELECT COUNT(*)
            FROM words
            WHERE words.hierarchy_id = hierarchies.id
          )
        SQL
      end
    end
  end
end
