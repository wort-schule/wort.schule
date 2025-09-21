class AddTextSearchIndexes < ActiveRecord::Migration[7.2]
  def change
    # Enable trigram extension for better text search if not already enabled
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    # Add GIN trigram indexes for faster ILIKE searches on frequently searched text columns
    add_index :words, :meaning, using: :gin, opclass: { meaning: :gin_trgm_ops }, name: "idx_words_meaning_trgm" unless index_exists?(:words, :meaning, name: "idx_words_meaning_trgm")
    add_index :words, :meaning_long, using: :gin, opclass: { meaning_long: :gin_trgm_ops }, name: "idx_words_meaning_long_trgm" unless index_exists?(:words, :meaning_long, name: "idx_words_meaning_long_trgm")

    # Partial indexes for specific word types to speed up filtered queries
    add_index :words, :name, where: "type = 'Noun'", name: "idx_nouns_name" unless index_exists?(:words, :name, name: "idx_nouns_name")
    add_index :words, :name, where: "type = 'Verb'", name: "idx_verbs_name" unless index_exists?(:words, :name, name: "idx_verbs_name")
    add_index :words, :name, where: "type = 'Adjective'", name: "idx_adjectives_name" unless index_exists?(:words, :name, name: "idx_adjectives_name")
    add_index :words, :name, where: "type = 'FunctionWord'", name: "idx_function_words_name" unless index_exists?(:words, :name, name: "idx_function_words_name")

    # Partial index for compound words which are frequently filtered
    add_index :words, :name, where: "compound = true", name: "idx_compound_words_name" unless index_exists?(:words, :name, name: "idx_compound_words_name")

    # Partial index for prototype words
    add_index :words, :name, where: "prototype = true", name: "idx_prototype_words_name" unless index_exists?(:words, :name, name: "idx_prototype_words_name")

    # Index for syllables searches (using btree for prefix matching)
    add_index :words, :syllables unless index_exists?(:words, :syllables)
    add_index :words, :written_syllables unless index_exists?(:words, :written_syllables)

    # Index for specific conjugation/declination fields that are frequently searched
    add_index :words, :plural, where: "plural IS NOT NULL AND plural != ''", name: "idx_words_plural" unless index_exists?(:words, :plural, name: "idx_words_plural")
    add_index :words, :past_participle, where: "past_participle IS NOT NULL AND past_participle != ''", name: "idx_words_past_participle" unless index_exists?(:words, :past_participle, name: "idx_words_past_participle")
    add_index :words, :participle, where: "participle IS NOT NULL AND participle != ''", name: "idx_words_participle" unless index_exists?(:words, :participle, name: "idx_words_participle")

    # Index for the example_sentences JSONB column for faster searches
    add_index :words, :example_sentences, using: :gin unless index_exists?(:words, :example_sentences)
  end
end