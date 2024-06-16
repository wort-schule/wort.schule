class MigrateWordViewSettings < ActiveRecord::Migration[7.1]
  def up
    add_reference :learning_groups, :word_view_setting, null: true, foreign_key: true

    execute <<~SQL
      INSERT
      INTO word_view_settings (name, theme_noun_id, theme_verb_id, theme_adjective_id, theme_function_word_id, font, owner_id, visibility, created_at, updated_at)
      (
        SELECT name, theme_noun_id, theme_verb_id, theme_adjective_id, theme_function_word_id, font, user_id, 'private', NOW(), NOW()
        FROM learning_groups
        WHERE
          theme_noun_id IS NOT NULL OR
          theme_verb_id IS NOT NULL OR
          theme_adjective_id IS NOT NULL OR
          theme_function_word_id IS NOT NULL OR
          font IS NOT NULL
      )
    SQL

    execute <<~SQL
      UPDATE learning_groups
      SET word_view_setting_id = word_view_settings.id
      FROM word_view_settings
      WHERE word_view_settings.owner_id = learning_groups.user_id AND word_view_settings.name = learning_groups.name
    SQL
  end

  def down
    remove_reference :learning_groups, :word_view_setting
  end
end
