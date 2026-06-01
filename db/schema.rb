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

ActiveRecord::Schema[8.1].define(version: 2026_06_01_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    t.index ["record_type", "record_id", "name"], name: "idx_active_storage_attachments_record_name"
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bulk_edit_changes", force: :cascade do |t|
    t.jsonb "applied_value", null: false
    t.bigint "bulk_edit_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "previous_value", null: false
    t.datetime "reverted_at"
    t.datetime "updated_at", null: false
    t.bigint "word_id"
    t.index ["bulk_edit_id", "word_id"], name: "index_bulk_edit_changes_on_bulk_edit_id_and_word_id", unique: true
    t.index ["bulk_edit_id"], name: "index_bulk_edit_changes_on_bulk_edit_id"
    t.index ["reverted_at"], name: "index_bulk_edit_changes_on_reverted_at"
    t.index ["word_id"], name: "index_bulk_edit_changes_on_word_id"
  end

  create_table "bulk_edits", force: :cascade do |t|
    t.integer "affected_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "field", null: false
    t.jsonb "intent_value", null: false
    t.string "missing_field"
    t.string "operation", null: false
    t.string "search_query"
    t.datetime "undone_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["undone_at"], name: "index_bulk_edits_on_undone_at"
    t.index ["user_id", "created_at"], name: "index_bulk_edits_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_bulk_edits_on_user_id"
  end

  create_table "change_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "state", default: "waiting_for_review", null: false
    t.bigint "successor_id"
    t.datetime "updated_at", null: false
    t.index ["state"], name: "index_change_groups_on_state"
    t.index ["successor_id"], name: "index_change_groups_on_successor_id"
  end

  create_table "compound_entities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "part_id"
    t.string "part_type"
    t.integer "pos"
    t.datetime "updated_at", null: false
    t.integer "word_id"
    t.index ["part_id"], name: "index_compound_entities_on_part_id"
    t.index ["part_type", "part_id"], name: "index_compound_entities_on_part_type_and_part_id"
    t.index ["word_id", "pos"], name: "idx_compound_entities_word_pos"
    t.index ["word_id"], name: "index_compound_entities_on_word_id"
  end

  create_table "compound_interfixes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "compound_phonem_reductions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "compound_postconfixes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "compound_preconfixes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "compound_vocalalternations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "genera", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "genus_keys", default: [], array: true
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["genus_keys"], name: "index_genera_on_genus_keys", using: :gin
  end

  create_table "global_settings", force: :cascade do |t|
    t.boolean "boolean_value"
    t.integer "integer_value"
    t.string "key", null: false
    t.text "string_value"
    t.index ["key"], name: "index_global_settings_on_key", unique: true
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "hierarchies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "top_hierarchy_id"
    t.datetime "updated_at", null: false
    t.integer "words_count", default: 0, null: false
    t.index ["top_hierarchy_id"], name: "index_hierarchies_on_top_hierarchy_id"
  end

  create_table "image_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "word_id", null: false
    t.index ["user_id"], name: "index_image_requests_on_user_id"
    t.index ["word_id", "user_id"], name: "index_image_requests_on_word_id_and_user_id", unique: true
    t.index ["word_id"], name: "index_image_requests_on_word_id"
  end

  create_table "keyword_effectiveness", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "inserted_at", null: false
    t.integer "keyword_id", null: false
    t.integer "keyword_position"
    t.boolean "led_to_correct"
    t.uuid "pick_id"
    t.datetime "picked_at"
    t.datetime "revealed_at"
    t.uuid "round_id"
    t.integer "word_id", null: false
    t.index ["inserted_at"], name: "index_keyword_effectiveness_on_inserted_at"
    t.index ["keyword_id"], name: "index_keyword_effectiveness_on_keyword_id"
    t.index ["led_to_correct", "keyword_position"], name: "idx_on_led_to_correct_keyword_position_20dbc20bd8"
    t.index ["pick_id"], name: "index_keyword_effectiveness_on_pick_id"
    t.index ["round_id"], name: "index_keyword_effectiveness_on_round_id"
    t.index ["word_id", "keyword_id"], name: "index_keyword_effectiveness_on_word_id_and_keyword_id"
  end

  create_table "keywords", id: false, force: :cascade do |t|
    t.integer "keyword_id"
    t.integer "word_id"
    t.index ["keyword_id", "word_id"], name: "index_keywords_on_keyword_id_and_word_id", unique: true
    t.index ["word_id", "keyword_id"], name: "index_keywords_on_word_id_and_keyword_id", unique: true
  end

  create_table "learning_group_memberships", force: :cascade do |t|
    t.string "access"
    t.datetime "created_at", null: false
    t.bigint "learning_group_id", null: false
    t.string "role", default: "member"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["access", "role", "learning_group_id"], name: "idx_learning_group_memberships_access_role"
    t.index ["learning_group_id", "user_id"], name: "index_learning_group_membership_unique", unique: true
    t.index ["learning_group_id"], name: "index_learning_group_memberships_on_learning_group_id"
    t.index ["role"], name: "index_learning_group_memberships_on_role"
    t.index ["user_id", "role"], name: "index_learning_group_memberships_on_user_id_and_role"
    t.index ["user_id"], name: "index_learning_group_memberships_on_user_id"
  end

  create_table "learning_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "invitable", default: false, null: false
    t.string "invitation_token"
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "word_view_setting_id"
    t.index ["invitation_token"], name: "index_learning_groups_on_invitation_token", unique: true
    t.index ["user_id"], name: "index_learning_groups_on_user_id"
    t.index ["word_view_setting_id"], name: "index_learning_groups_on_word_view_setting_id"
  end

  create_table "learning_pleas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "learning_group_id", null: false
    t.bigint "list_id", null: false
    t.datetime "updated_at", null: false
    t.index ["learning_group_id"], name: "index_learning_pleas_on_learning_group_id"
    t.index ["list_id"], name: "index_learning_pleas_on_list_id"
  end

  create_table "lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "flashcard_section"
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "visibility"
    t.integer "words_count", default: 0, null: false
    t.index ["user_id", "flashcard_section"], name: "idx_users_flashcard_section", where: "(flashcard_section IS NOT NULL)"
    t.index ["user_id", "visibility"], name: "index_lists_on_user_id_and_visibility"
    t.index ["user_id"], name: "index_lists_on_user_id"
    t.index ["visibility"], name: "index_lists_on_visibility"
  end

  create_table "lists_words", id: false, force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "word_id", null: false
    t.index ["list_id", "word_id"], name: "idx_lists_words_composite"
    t.index ["list_id"], name: "index_lists_words_on_list_id"
    t.index ["word_id"], name: "index_lists_words_on_word_id"
  end

  create_table "llm_prompts", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "identifier", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_llm_prompts_on_identifier", unique: true
  end

  create_table "llm_services", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.string "api_key"
    t.datetime "created_at", null: false
    t.string "endpoint"
    t.string "model", null: false
    t.string "name", null: false
    t.string "service_klass", null: false
    t.datetime "updated_at", null: false
  end

  create_table "new_words", force: :cascade do |t|
    t.bigint "change_group_id", null: false
    t.datetime "created_at", null: false
    t.bigint "created_word_id"
    t.bigint "duplicate_word_id"
    t.string "llm_name"
    t.string "llm_topic"
    t.string "name", null: false
    t.string "topic", null: false
    t.datetime "updated_at", null: false
    t.string "word_type", null: false
    t.index ["change_group_id"], name: "index_new_words_on_change_group_id"
    t.index ["created_word_id"], name: "index_new_words_on_created_word_id"
    t.index ["duplicate_word_id"], name: "index_new_words_on_duplicate_word_id"
    t.index ["name", "topic", "word_type"], name: "index_new_words_on_name_and_topic_and_word_type"
  end

  create_table "opposites", id: false, force: :cascade do |t|
    t.integer "opposite_id"
    t.integer "word_id"
    t.index ["opposite_id", "word_id"], name: "index_opposites_on_opposite_id_and_word_id", unique: true
    t.index ["word_id", "opposite_id"], name: "index_opposites_on_word_id_and_opposite_id", unique: true
  end

  create_table "phenomenons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: ""
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "words_count", default: 0, null: false
  end

  create_table "phenomenons_words", id: false, force: :cascade do |t|
    t.bigint "phenomenon_id", null: false
    t.bigint "word_id", null: false
    t.index ["phenomenon_id", "word_id"], name: "index_phenomenons_words_on_phenomenon_id_and_word_id"
    t.index ["word_id", "phenomenon_id"], name: "index_phenomenons_words_on_word_id_and_phenomenon_id", unique: true
  end

  create_table "postfixes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "prefixes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "inseparable", default: false, null: false
    t.string "name"
    t.string "prefix_type", default: "Verb"
    t.boolean "separable", default: false, null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "reviewable_id", null: false
    t.string "reviewable_type", null: false
    t.bigint "reviewer_id", null: false
    t.string "state", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewable_type", "reviewable_id", "state"], name: "idx_reviews_on_reviewable_and_state"
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "rimes", id: false, force: :cascade do |t|
    t.integer "rime_id"
    t.integer "word_id"
    t.index ["rime_id", "word_id"], name: "index_rimes_on_rime_id_and_word_id", unique: true
    t.index ["word_id", "rime_id"], name: "index_rimes_on_word_id_and_rime_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sources", force: :cascade do |t|
    t.string "author"
    t.string "comment"
    t.datetime "created_at", null: false
    t.string "licence"
    t.string "name"
    t.string "source_url"
    t.datetime "updated_at", null: false
    t.boolean "visible", default: true, null: false
    t.integer "words_count", default: 0, null: false
  end

  create_table "sources_words", id: false, force: :cascade do |t|
    t.bigint "source_id", null: false
    t.bigint "word_id", null: false
    t.index ["source_id", "word_id"], name: "index_sources_words_on_source_id_and_word_id"
    t.index ["source_id"], name: "idx_sources_words_source_id"
    t.index ["word_id", "source_id"], name: "index_sources_words_on_word_id_and_source_id", unique: true
  end

  create_table "strategies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: ""
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "words_count", default: 0, null: false
  end

  create_table "strategies_words", id: false, force: :cascade do |t|
    t.bigint "strategy_id", null: false
    t.bigint "word_id", null: false
    t.index ["strategy_id", "word_id"], name: "index_strategies_words_on_strategy_id_and_word_id"
    t.index ["word_id", "strategy_id"], name: "index_strategies_words_on_word_id_and_strategy_id", unique: true
  end

  create_table "synonyms", id: false, force: :cascade do |t|
    t.integer "synonym_id"
    t.integer "word_id"
    t.index ["synonym_id", "word_id"], name: "index_synonyms_on_synonym_id_and_word_id", unique: true
    t.index ["word_id", "synonym_id"], name: "index_synonyms_on_word_id_and_synonym_id", unique: true
  end

  create_table "themes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.text "template"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "visibility", default: "private"
    t.string "word_type", default: "noun"
    t.index ["name"], name: "index_themes_on_name", unique: true
    t.index ["user_id", "visibility"], name: "index_themes_on_user_id_and_visibility"
    t.index ["user_id"], name: "index_themes_on_user_id"
    t.index ["visibility"], name: "index_themes_on_visibility"
    t.index ["word_type"], name: "index_themes_on_word_type"
  end

  create_table "topics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "words_count", default: 0, null: false
  end

  create_table "topics_words", id: false, force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.bigint "word_id", null: false
    t.index ["topic_id", "word_id"], name: "index_topics_words_on_topic_id_and_word_id"
    t.index ["topic_id"], name: "idx_topics_words_topic_id"
    t.index ["word_id", "topic_id"], name: "index_topics_words_on_word_id_and_topic_id", unique: true
  end

  create_table "unlisted_keywords", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "new_word_id"
    t.string "state", default: "new", null: false
    t.datetime "updated_at", null: false
    t.bigint "word_id", null: false
    t.bigint "word_import_id", null: false
    t.string "word_type", null: false
    t.index ["new_word_id"], name: "index_unlisted_keywords_on_new_word_id"
    t.index ["state"], name: "index_unlisted_keywords_on_state"
    t.index ["word_import_id"], name: "index_unlisted_keywords_on_word_import_id"
    t.index ["word_type", "word_id"], name: "index_unlisted_keywords_on_word"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "review_attributes", default: [], null: false, array: true
    t.boolean "review_new_words", default: true, null: false
    t.string "role", default: "Guest"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.bigint "word_view_setting_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["word_view_setting_id"], name: "index_users_on_word_view_setting_id"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.jsonb "object"
    t.jsonb "object_changes"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "word_attribute_edits", force: :cascade do |t|
    t.string "attribute_name", null: false
    t.bigint "change_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.bigint "word_id", null: false
    t.string "word_type", null: false
    t.index ["change_group_id"], name: "index_word_attribute_edits_on_change_group_id"
    t.index ["word_type", "word_id", "attribute_name"], name: "idx_word_attr_edits_on_word_and_attr"
    t.index ["word_type", "word_id"], name: "index_word_attribute_edits_on_word"
  end

  create_table "word_imports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.string "name"
    t.string "state", default: "new", null: false
    t.string "topic"
    t.datetime "updated_at", null: false
    t.string "word_type"
    t.index ["name", "topic", "word_type"], name: "index_word_imports_on_name_and_topic_and_word_type"
    t.index ["state"], name: "index_word_imports_on_state"
  end

  create_table "word_llm_invocations", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "error"
    t.string "invocation_type", null: false
    t.string "key", null: false
    t.string "state", default: "new", null: false
    t.datetime "updated_at", null: false
    t.index ["invocation_type"], name: "index_word_llm_invocations_on_invocation_type"
    t.index ["key"], name: "index_word_llm_invocations_on_key"
    t.index ["state"], name: "index_word_llm_invocations_on_state"
  end

  create_table "word_view_settings", force: :cascade do |t|
    t.boolean "color_syllables", default: false, null: false
    t.datetime "created_at", null: false
    t.string "font"
    t.string "genus_wording", default: "default", null: false
    t.string "name", null: false
    t.string "numerus_wording", default: "default", null: false
    t.bigint "owner_id", null: false
    t.boolean "show_fresch_symbols", default: true, null: false
    t.boolean "show_gender_symbols", default: true, null: false
    t.boolean "show_horizontal_lines", default: false, null: false
    t.boolean "show_house", default: false, null: false
    t.boolean "show_montessori_symbols", default: true, null: false
    t.boolean "show_syllable_arcs", default: true, null: false
    t.bigint "theme_adjective_id"
    t.bigint "theme_function_word_id"
    t.bigint "theme_noun_id"
    t.bigint "theme_verb_id"
    t.datetime "updated_at", null: false
    t.string "visibility", default: "private"
    t.string "word_type_wording", default: "default", null: false
    t.index ["owner_id", "visibility"], name: "idx_word_view_settings_owner_visibility"
    t.index ["owner_id", "visibility"], name: "index_word_view_settings_on_owner_id_and_visibility"
    t.index ["owner_id"], name: "index_word_view_settings_on_owner_id"
    t.index ["theme_adjective_id"], name: "index_word_view_settings_on_theme_adjective_id"
    t.index ["theme_function_word_id"], name: "index_word_view_settings_on_theme_function_word_id"
    t.index ["theme_noun_id"], name: "index_word_view_settings_on_theme_noun_id"
    t.index ["theme_verb_id"], name: "index_word_view_settings_on_theme_verb_id"
    t.index ["visibility"], name: "index_word_view_settings_on_visibility"
  end

  create_table "words", force: :cascade do |t|
    t.boolean "absolute", default: false, null: false
    t.string "case_1_plural", default: ""
    t.string "case_1_singular", default: ""
    t.string "case_2_plural", default: ""
    t.string "case_2_singular", default: ""
    t.string "case_3_plural", default: ""
    t.string "case_3_singular", default: ""
    t.string "case_4_plural", default: ""
    t.string "case_4_singular", default: ""
    t.string "cologne_phonetics", default: [], array: true
    t.string "comparative", default: ""
    t.boolean "compound", default: false, null: false
    t.string "consonant_vowel"
    t.datetime "created_at", null: false
    t.jsonb "example_sentences", default: [], null: false
    t.boolean "example_sentences_verified", default: false, null: false
    t.boolean "foreign", default: false, null: false
    t.integer "function_type"
    t.bigint "genus_feminine_id"
    t.bigint "genus_id"
    t.bigint "genus_masculine_id"
    t.bigint "genus_neuter_id"
    t.bigint "hierarchy_id"
    t.bigint "hit_counter", default: 0, null: false
    t.string "image_alt_text"
    t.string "imperative_plural"
    t.string "imperative_singular"
    t.boolean "irregular_comparison", default: false, null: false
    t.boolean "irregular_declination", default: false, null: false
    t.string "meaning", default: ""
    t.string "meaning_long", default: ""
    t.boolean "modal", default: false, null: false
    t.string "name"
    t.string "participle", default: ""
    t.string "past_participle", default: ""
    t.string "past_plural_1", default: ""
    t.string "past_plural_2", default: ""
    t.string "past_plural_3", default: ""
    t.string "past_singular_1", default: ""
    t.string "past_singular_2", default: ""
    t.string "past_singular_3", default: ""
    t.boolean "perfect_haben", default: false, null: false
    t.boolean "perfect_sein", default: false, null: false
    t.string "plural", default: ""
    t.boolean "pluraletantum", default: false, null: false
    t.bigint "postfix_id"
    t.bigint "prefix_id"
    t.string "present_plural_1", default: ""
    t.string "present_plural_2", default: ""
    t.string "present_plural_3", default: ""
    t.string "present_singular_1", default: ""
    t.string "present_singular_2", default: ""
    t.string "present_singular_3", default: ""
    t.boolean "prototype", default: false, null: false
    t.boolean "singularetantum", default: false, null: false
    t.string "slug"
    t.boolean "strong", default: false, null: false
    t.boolean "subjectless", default: false, null: false
    t.string "superlative", default: ""
    t.string "syllables", default: ""
    t.boolean "syllables_verified", default: false, null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.string "wiktionary_syllables"
    t.boolean "with_tts", default: true, null: false
    t.string "written_syllables", default: ""
    t.index "lower((name)::text)", name: "idx_words_lower_name"
    t.index ["cologne_phonetics"], name: "index_words_on_cologne_phonetics", using: :gin
    t.index ["compound"], name: "index_words_on_compound"
    t.index ["consonant_vowel"], name: "index_words_on_consonant_vowel"
    t.index ["example_sentences"], name: "index_words_on_example_sentences", using: :gin
    t.index ["foreign", "prototype", "compound", "type"], name: "idx_words_foreign_prototype_compound"
    t.index ["genus_feminine_id"], name: "index_words_on_genus_feminine_id"
    t.index ["genus_id"], name: "index_words_on_genus_id"
    t.index ["genus_masculine_id"], name: "index_words_on_genus_masculine_id"
    t.index ["genus_neuter_id"], name: "index_words_on_genus_neuter_id"
    t.index ["hierarchy_id", "name"], name: "index_words_on_hierarchy_id_and_name"
    t.index ["hierarchy_id"], name: "index_words_on_hierarchy_id"
    t.index ["hit_counter"], name: "idx_words_hit_counter_desc", order: :desc
    t.index ["hit_counter"], name: "index_words_on_hit_counter"
    t.index ["meaning"], name: "idx_words_meaning_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["meaning_long"], name: "idx_words_meaning_long_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["name"], name: "idx_adjectives_name", where: "((type)::text = 'Adjective'::text)"
    t.index ["name"], name: "idx_compound_words_name", where: "(compound = true)"
    t.index ["name"], name: "idx_function_words_name", where: "((type)::text = 'FunctionWord'::text)"
    t.index ["name"], name: "idx_nouns_name", where: "((type)::text = 'Noun'::text)"
    t.index ["name"], name: "idx_prototype_words_name", where: "(prototype = true)"
    t.index ["name"], name: "idx_verbs_name", where: "((type)::text = 'Verb'::text)"
    t.index ["name"], name: "index_words_on_name"
    t.index ["participle"], name: "idx_words_participle", where: "((participle IS NOT NULL) AND ((participle)::text <> ''::text))"
    t.index ["past_participle"], name: "idx_words_past_participle", where: "((past_participle IS NOT NULL) AND ((past_participle)::text <> ''::text))"
    t.index ["plural"], name: "idx_words_plural", where: "((plural IS NOT NULL) AND ((plural)::text <> ''::text))"
    t.index ["postfix_id"], name: "index_words_on_postfix_id"
    t.index ["prefix_id"], name: "index_words_on_prefix_id"
    t.index ["slug"], name: "index_words_on_slug", unique: true
    t.index ["syllables"], name: "index_words_on_syllables"
    t.index ["type", "name", "hit_counter"], name: "idx_words_type_name_hit_counter"
    t.index ["type", "name"], name: "index_words_on_type_and_name"
    t.index ["type"], name: "index_words_on_type"
    t.index ["with_tts"], name: "idx_words_with_tts", where: "(with_tts = true)"
    t.index ["written_syllables"], name: "index_words_on_written_syllables"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bulk_edit_changes", "bulk_edits"
  add_foreign_key "bulk_edit_changes", "words", on_delete: :nullify
  add_foreign_key "bulk_edits", "users", on_delete: :restrict
  add_foreign_key "change_groups", "change_groups", column: "successor_id"
  add_foreign_key "hierarchies", "hierarchies", column: "top_hierarchy_id"
  add_foreign_key "image_requests", "users"
  add_foreign_key "image_requests", "words"
  add_foreign_key "learning_group_memberships", "learning_groups"
  add_foreign_key "learning_groups", "word_view_settings"
  add_foreign_key "learning_pleas", "learning_groups"
  add_foreign_key "learning_pleas", "lists"
  add_foreign_key "lists", "users"
  add_foreign_key "new_words", "change_groups"
  add_foreign_key "new_words", "words", column: "created_word_id"
  add_foreign_key "new_words", "words", column: "duplicate_word_id"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "themes", "users"
  add_foreign_key "unlisted_keywords", "new_words"
  add_foreign_key "unlisted_keywords", "word_imports"
  add_foreign_key "users", "word_view_settings"
  add_foreign_key "word_view_settings", "themes", column: "theme_adjective_id"
  add_foreign_key "word_view_settings", "themes", column: "theme_function_word_id"
  add_foreign_key "word_view_settings", "themes", column: "theme_noun_id"
  add_foreign_key "word_view_settings", "themes", column: "theme_verb_id"
  add_foreign_key "word_view_settings", "users", column: "owner_id"
  add_foreign_key "words", "hierarchies"
  add_foreign_key "words", "postfixes"
  add_foreign_key "words", "prefixes"

  create_view "requested_word_images", sql_definition: <<-SQL
      SELECT words.name,
      words.meaning,
      requests.request_count
     FROM (words
       JOIN ( SELECT ir.word_id,
              count(ir.word_id) AS request_count
             FROM image_requests ir
            GROUP BY ir.word_id) requests ON ((words.id = requests.word_id)))
    ORDER BY words.hit_counter DESC, words.name;
  SQL
  create_view "reviewers", sql_definition: <<-SQL
      SELECT cg.id AS change_group_id,
      r.reviewer_id
     FROM (change_groups cg
       JOIN reviews r ON ((((r.reviewable_type)::text = 'ChangeGroup'::text) AND (r.reviewable_id = cg.id))));
  SQL
end
