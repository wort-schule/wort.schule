class CreateDataModel < ActiveRecord::Migration[7.0]
  def change
    create_table "adjectives", force: :cascade do |t|
      t.string "comparative", default: ""
      t.string "superlative", default: ""
      t.boolean "absolute"
      t.boolean "irregular_declination"
      t.boolean "irregular_comparison"
    end

    create_table "compound_entities", force: :cascade do |t|
      t.integer "word_id"
      t.integer "pos"
      t.integer "part_id"
      t.string "part_type"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "compound_interfixes", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "compound_phonemreductions", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "compound_postconfixes", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "compound_preconfixes", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "compound_vocalalternations", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "example_sentences", force: :cascade do |t|
      t.string "sentence"
      t.bigint "word_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["word_id"], name: "index_example_sentences_on_word_id"
    end

    create_table "function_words", force: :cascade do |t|
      t.integer "function_type"
    end

    create_table "genus", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "hierarchies", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "top_hierarchy_id"
      t.index ["top_hierarchy_id"], name: "index_hierarchies_on_top_hierarchy_id"
    end

    create_table "keywords", id: false, force: :cascade do |t|
      t.integer "word_id"
      t.integer "keyword_id"
      t.index ["keyword_id", "word_id"], name: "index_keywords_on_keyword_id_and_word_id", unique: true
      t.index ["word_id", "keyword_id"], name: "index_keywords_on_word_id_and_keyword_id", unique: true
    end

    create_table "nouns", force: :cascade do |t|
      t.string "plural", default: ""
      t.bigint "genus_id"
      t.bigint "genus_masculine_id"
      t.bigint "genus_feminine_id"
      t.bigint "genus_neuter_id"
      t.string "case_1_singular", default: ""
      t.string "case_1_plural", default: ""
      t.string "case_2_singular", default: ""
      t.string "case_2_plural", default: ""
      t.string "case_3_singular", default: ""
      t.string "case_3_plural", default: ""
      t.string "case_4_singular", default: ""
      t.string "case_4_plural", default: ""
      t.integer "casus_empty"
      t.boolean "pluraletantum"
      t.boolean "singularetantum"
      t.index ["genus_feminine_id"], name: "index_nouns_on_genus_feminine_id"
      t.index ["genus_id"], name: "index_nouns_on_genus_id"
      t.index ["genus_masculine_id"], name: "index_nouns_on_genus_masculine_id"
      t.index ["genus_neuter_id"], name: "index_nouns_on_genus_neuter_id"
    end

    create_table "opposites", id: false, force: :cascade do |t|
      t.integer "word_id"
      t.integer "opposite_id"
      t.index ["opposite_id", "word_id"], name: "index_opposites_on_opposite_id_and_word_id", unique: true
      t.index ["word_id", "opposite_id"], name: "index_opposites_on_word_id_and_opposite_id", unique: true
    end

    create_table "phenomenons", force: :cascade do |t|
      t.string "name"
      t.string "description", default: ""
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "phenomenons_words", id: false, force: :cascade do |t|
      t.bigint "word_id", null: false
      t.bigint "phenomenon_id", null: false
      t.index ["phenomenon_id", "word_id"], name: "index_phenomenons_words_on_phenomenon_id_and_word_id"
      t.index ["word_id", "phenomenon_id"], name: "index_phenomenons_words_on_word_id_and_phenomenon_id", unique: true
    end

    create_table "postfixes", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "prefixes", force: :cascade do |t|
      t.string "name"
      t.boolean "separable"
      t.boolean "inseparable"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "prefix_type", default: "Verb"
    end

    create_table "random_topics", force: :cascade do |t|
      t.string "name"
      t.integer "score", default: 1
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "rimes", id: false, force: :cascade do |t|
      t.integer "word_id"
      t.integer "rime_id"
      t.index ["rime_id", "word_id"], name: "index_rimes_on_rime_id_and_word_id", unique: true
      t.index ["word_id", "rime_id"], name: "index_rimes_on_word_id_and_rime_id", unique: true
    end

    create_table "sources", force: :cascade do |t|
      t.string "name"
      t.string "author"
      t.string "licence"
      t.string "source_url"
      t.string "comment"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "sources_words", id: false, force: :cascade do |t|
      t.bigint "word_id", null: false
      t.bigint "source_id", null: false
      t.index ["source_id", "word_id"], name: "index_sources_words_on_source_id_and_word_id"
      t.index ["word_id", "source_id"], name: "index_sources_words_on_word_id_and_source_id", unique: true
    end

    create_table "strategies", force: :cascade do |t|
      t.string "name"
      t.string "description", default: ""
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "strategies_words", id: false, force: :cascade do |t|
      t.bigint "word_id", null: false
      t.bigint "strategy_id", null: false
      t.index ["strategy_id", "word_id"], name: "index_strategies_words_on_strategy_id_and_word_id"
      t.index ["word_id", "strategy_id"], name: "index_strategies_words_on_word_id_and_strategy_id", unique: true
    end

    create_table "synonyms", id: false, force: :cascade do |t|
      t.integer "word_id"
      t.integer "synonym_id"
      t.index ["synonym_id", "word_id"], name: "index_synonyms_on_synonym_id_and_word_id", unique: true
      t.index ["word_id", "synonym_id"], name: "index_synonyms_on_word_id_and_synonym_id", unique: true
    end

    create_table "topics", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "topics_words", id: false, force: :cascade do |t|
      t.bigint "word_id", null: false
      t.bigint "topic_id", null: false
      t.index ["topic_id", "word_id"], name: "index_topics_words_on_topic_id_and_word_id"
      t.index ["word_id", "topic_id"], name: "index_topics_words_on_word_id_and_topic_id", unique: true
    end

    create_table "verbs", force: :cascade do |t|
      t.string "participle", default: ""
      t.string "past_participle", default: ""
      t.string "present_singular_1", default: ""
      t.string "present_singular_2", default: ""
      t.string "present_singular_3", default: ""
      t.string "present_plural_1", default: ""
      t.string "present_plural_2", default: ""
      t.string "present_plural_3", default: ""
      t.string "past_singular_1", default: ""
      t.string "past_singular_2", default: ""
      t.string "past_singular_3", default: ""
      t.string "past_plural_1", default: ""
      t.string "past_plural_2", default: ""
      t.string "past_plural_3", default: ""
      t.integer "present_empty"
      t.integer "past_empty"
      t.boolean "subjectless"
      t.boolean "perfect_haben"
      t.boolean "perfect_sein"
      t.string "imperative_singular"
      t.string "imperative_plural"
      t.boolean "modal"
      t.boolean "strong"
    end

    create_table "words", force: :cascade do |t|
      t.bigint "hierarchy_id"
      t.string "actable_type"
      t.bigint "actable_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "meaning", default: ""
      t.string "meaning_long", default: ""
      t.boolean "prototype"
      t.boolean "foreign"
      t.boolean "compound"
      t.bigint "prefix_id"
      t.bigint "postfix_id"
      t.string "name"
      t.string "consonant_vowel"
      t.string "syllables", default: ""
      t.string "written_syllables", default: ""
      t.index ["actable_type", "actable_id"], name: "index_words_on_actable_type_and_actable_id"
      t.index ["hierarchy_id"], name: "index_words_on_hierarchy_id"
      t.index ["postfix_id"], name: "index_words_on_postfix_id"
      t.index ["prefix_id"], name: "index_words_on_prefix_id"
    end

    add_foreign_key "example_sentences", "words"
    add_foreign_key "hierarchies", "hierarchies", column: "top_hierarchy_id"
    add_foreign_key "nouns", "genus", column: "genus_id"
    add_foreign_key "nouns", "nouns", column: "genus_feminine_id"
    add_foreign_key "nouns", "nouns", column: "genus_masculine_id"
    add_foreign_key "nouns", "nouns", column: "genus_neuter_id"
    add_foreign_key "words", "hierarchies"
    add_foreign_key "words", "postfixes"
    add_foreign_key "words", "prefixes"
  end
end
