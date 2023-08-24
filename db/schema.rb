# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_23_174305) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
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

  create_table "function_words", force: :cascade do |t|
    t.integer "function_type"
  end

  create_table "genus", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
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

  create_table "learning_group_memberships", force: :cascade do |t|
    t.bigint "learning_group_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access"
    t.string "role", default: "member"
    t.index ["learning_group_id", "user_id"], name: "index_learning_group_membership_unique", unique: true
    t.index ["learning_group_id"], name: "index_learning_group_memberships_on_learning_group_id"
    t.index ["user_id"], name: "index_learning_group_memberships_on_user_id"
  end

  create_table "learning_groups", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.boolean "invitable", default: false, null: false
    t.bigint "theme_noun_id"
    t.bigint "theme_verb_id"
    t.bigint "theme_adjective_id"
    t.bigint "theme_function_word_id"
    t.index ["invitation_token"], name: "index_learning_groups_on_invitation_token", unique: true
    t.index ["theme_adjective_id"], name: "index_learning_groups_on_theme_adjective_id"
    t.index ["theme_function_word_id"], name: "index_learning_groups_on_theme_function_word_id"
    t.index ["theme_noun_id"], name: "index_learning_groups_on_theme_noun_id"
    t.index ["theme_verb_id"], name: "index_learning_groups_on_theme_verb_id"
    t.index ["user_id"], name: "index_learning_groups_on_user_id"
  end

  create_table "learning_pleas", force: :cascade do |t|
    t.bigint "learning_group_id", null: false
    t.bigint "list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["learning_group_id"], name: "index_learning_pleas_on_learning_group_id"
    t.index ["list_id"], name: "index_learning_pleas_on_list_id"
  end

  create_table "lists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "description"
    t.string "visibility"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "flashcard_section"
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "lists_words", id: false, force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "word_id", null: false
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
    t.boolean "separable", default: false, null: false
    t.boolean "inseparable", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prefix_type", default: "Verb"
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
    t.boolean "visible", default: true, null: false
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

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "template"
    t.string "word_type", default: "noun"
    t.string "visibility", default: "private"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_themes_on_name", unique: true
    t.index ["user_id"], name: "index_themes_on_user_id"
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

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role", default: "Guest"
    t.bigint "theme_noun_id"
    t.bigint "theme_verb_id"
    t.bigint "theme_adjective_id"
    t.bigint "theme_function_word_id"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["theme_adjective_id"], name: "index_users_on_theme_adjective_id"
    t.index ["theme_function_word_id"], name: "index_users_on_theme_function_word_id"
    t.index ["theme_noun_id"], name: "index_users_on_theme_noun_id"
    t.index ["theme_verb_id"], name: "index_users_on_theme_verb_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.datetime "created_at"
    t.jsonb "object"
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "words", force: :cascade do |t|
    t.bigint "hierarchy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "meaning", default: ""
    t.string "meaning_long", default: ""
    t.boolean "prototype", default: false, null: false
    t.boolean "foreign", default: false, null: false
    t.boolean "compound", default: false, null: false
    t.bigint "prefix_id"
    t.bigint "postfix_id"
    t.string "name"
    t.string "consonant_vowel"
    t.string "syllables", default: ""
    t.string "written_syllables", default: ""
    t.string "slug"
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
    t.boolean "pluraletantum", default: false, null: false
    t.boolean "singularetantum", default: false, null: false
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
    t.boolean "subjectless", default: false, null: false
    t.boolean "perfect_haben", default: false, null: false
    t.boolean "perfect_sein", default: false, null: false
    t.string "imperative_singular"
    t.string "imperative_plural"
    t.boolean "modal", default: false, null: false
    t.boolean "strong", default: false, null: false
    t.string "comparative", default: ""
    t.string "superlative", default: ""
    t.boolean "absolute", default: false, null: false
    t.boolean "irregular_declination", default: false, null: false
    t.boolean "irregular_comparison", default: false, null: false
    t.integer "function_type"
    t.string "type", null: false
    t.jsonb "example_sentences", default: [], null: false
    t.bigint "hit_counter", default: 0, null: false
    t.boolean "with_tts", default: true, null: false
    t.string "cologne_phonetics", default: [], array: true
    t.index ["genus_feminine_id"], name: "index_words_on_genus_feminine_id"
    t.index ["genus_id"], name: "index_words_on_genus_id"
    t.index ["genus_masculine_id"], name: "index_words_on_genus_masculine_id"
    t.index ["genus_neuter_id"], name: "index_words_on_genus_neuter_id"
    t.index ["hierarchy_id"], name: "index_words_on_hierarchy_id"
    t.index ["postfix_id"], name: "index_words_on_postfix_id"
    t.index ["prefix_id"], name: "index_words_on_prefix_id"
    t.index ["slug"], name: "index_words_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "hierarchies", "hierarchies", column: "top_hierarchy_id"
  add_foreign_key "learning_group_memberships", "learning_groups"
  add_foreign_key "learning_group_memberships", "users"
  add_foreign_key "learning_groups", "themes", column: "theme_adjective_id"
  add_foreign_key "learning_groups", "themes", column: "theme_function_word_id"
  add_foreign_key "learning_groups", "themes", column: "theme_noun_id"
  add_foreign_key "learning_groups", "themes", column: "theme_verb_id"
  add_foreign_key "learning_groups", "users"
  add_foreign_key "learning_pleas", "learning_groups"
  add_foreign_key "learning_pleas", "lists"
  add_foreign_key "lists", "users"
  add_foreign_key "themes", "users"
  add_foreign_key "users", "themes", column: "theme_adjective_id"
  add_foreign_key "users", "themes", column: "theme_function_word_id"
  add_foreign_key "users", "themes", column: "theme_noun_id"
  add_foreign_key "users", "themes", column: "theme_verb_id"
  add_foreign_key "words", "hierarchies"
  add_foreign_key "words", "postfixes"
  add_foreign_key "words", "prefixes"
end
