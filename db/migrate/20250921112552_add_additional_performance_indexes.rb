class AddAdditionalPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    # Add indexes for frequent filter queries
    add_index :words, :with_tts, where: "with_tts = true", name: "idx_words_with_tts"
    add_index :words, :hit_counter, order: {hit_counter: :desc}, name: "idx_words_hit_counter_desc"

    # Add indexes for join tables if not already present
    unless index_exists?(:topics_words, :topic_id)
      add_index :topics_words, :topic_id, name: "idx_topics_words_topic_id"
    end

    unless index_exists?(:sources_words, :source_id)
      add_index :sources_words, :source_id, name: "idx_sources_words_source_id"
    end
  end
end
