class AddCounterCacheColumns < ActiveRecord::Migration[7.2]
  def change
    # Add counter cache for lists words count
    add_column :lists, :words_count, :integer, default: 0, null: false

    # Add counter cache for phenomenons words count
    add_column :phenomenons, :words_count, :integer, default: 0, null: false

    # Add counter cache for strategies words count
    add_column :strategies, :words_count, :integer, default: 0, null: false

    # Backfill counter caches
    reversible do |dir|
      dir.up do
        # Backfill lists words_count
        execute <<-SQL.squish
          UPDATE lists
          SET words_count = (
            SELECT COUNT(*)
            FROM lists_words
            WHERE lists_words.list_id = lists.id
          )
        SQL

        # Backfill phenomenons words_count
        execute <<-SQL.squish
          UPDATE phenomenons
          SET words_count = (
            SELECT COUNT(*)
            FROM phenomenons_words
            WHERE phenomenons_words.phenomenon_id = phenomenons.id
          )
        SQL

        # Backfill strategies words_count
        execute <<-SQL.squish
          UPDATE strategies
          SET words_count = (
            SELECT COUNT(*)
            FROM strategies_words
            WHERE strategies_words.strategy_id = strategies.id
          )
        SQL
      end
    end
  end
end
