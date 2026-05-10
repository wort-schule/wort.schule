# frozen_string_literal: true

require "application_system_test_case"

class ThemesTest < ApplicationSystemTestCase
  setup do
    @klass = Theme
    @admin = create(:admin, first_name: "Sarah", last_name: "Muster")
    login_as @admin
  end

  test "shows existing entries" do
    entry = create(@klass.model_name.singular)

    visit public_send(:"#{@klass.model_name.plural}_path")

    assert_text entry.name
  end

  test "edits an entry" do
    entry = create(@klass.model_name.singular)

    visit public_send(:"#{@klass.model_name.plural}_path")

    click_on entry.name
    click_on t("actions.edit")
    fill_in "#{@klass.model_name.singular}[name]", with: "Anderer Name"
    click_on t("helpers.submit.update")

    entry.reload
    assert_equal "Anderer Name", entry.name
  end

  test "shows an error when invalid" do
    entry = create(@klass.model_name.singular)

    visit public_send(:"#{@klass.model_name.plural}_path")

    click_on entry.name
    click_on t("actions.edit")
    fill_in "#{@klass.model_name.singular}[name]", with: ""

    assert_no_difference -> { @klass.count } do
      click_on t("helpers.submit.update")
    end

    assert_text t("errors.messages.blank")
  end

  test "deletes an entry" do
    entry = create(@klass.model_name.singular)

    visit public_send(:"#{@klass.model_name.plural}_path")

    click_on entry.name
    click_on t("actions.edit")
    click_on t("actions.delete")

    assert_raises ActiveRecord::RecordNotFound do
      entry.reload
    end
  end

  test "copies an existing theme" do
    entry = create(@klass.model_name.singular)

    visit theme_path(entry)

    click_on t("actions.copy")

    assert_difference -> { Theme.count }, +1 do
      click_on t("helpers.submit.create")
    end

    theme = Theme.find_by(name: "Kopie von #{entry.name}")

    assert_equal entry.description, theme.description
    assert_equal entry.template, theme.template.gsub("\r\n", "\n")
    assert_equal entry.word_type, theme.word_type
    assert_equal :private, theme.visibility.to_sym
    assert_equal User.find(@admin.id), theme.user
  end

  test "creates an entry without existing entries" do
    visit public_send(:"#{@klass.model_name.plural}_path")
    click_on t("#{@klass.model_name.plural}.index.new")
    # Two-step Stimulus reveal: select word_type, click Continue, fill the
    # rest. The template field is wrapped by CodeMirror — the underlying
    # textarea is hidden, so type into the editor surface instead.
    click_on t("actions.continue")

    fill_in "#{@klass.model_name.singular}[name]", with: "Neuer Name"
    find(".cm-editor").click
    page.driver.browser.keyboard.type "Template Test"

    assert_difference -> { @klass.count }, +1 do
      click_on t("helpers.submit.create")
    end

    assert_equal "Neuer Name", @klass.last.name
    # CodeMirror prefills the editor with a default template for the chosen
    # word_type, so the saved value is "<default template>Template Test".
    assert_includes @klass.last.template, "Template Test"
  end

  test "shows an error when invalid on creation" do
    visit public_send(:"#{@klass.model_name.plural}_path")
    click_on t("#{@klass.model_name.plural}.index.new")
    click_on t("actions.continue")

    assert_no_difference -> { @klass.count } do
      click_on t("helpers.submit.create")
    end

    # Error renders inside the (collapsed) form panel — match the full text.
    assert_includes page.text(:all), t("errors.messages.blank")
  end

  test "does not allow JavaScript content" do
    visit public_send(:"#{@klass.model_name.plural}_path")
    click_on t("#{@klass.model_name.plural}.index.new")
    click_on t("actions.continue")

    fill_in "#{@klass.model_name.singular}[name]", with: "Neuer Name"
    find(".cm-editor").click
    page.driver.browser.keyboard.type "JavaScriptTemplate <script>document.write('hello world')</script>"

    assert_difference -> { @klass.count }, +1 do
      click_on t("helpers.submit.create")
    end

    new_theme = @klass.last
    assert_equal "Neuer Name", new_theme.name
    assert_equal "noun", new_theme.word_type
    new_theme.update!(template: "JavaScriptTemplate <script>document.write('hello world')</script>")
    assert_equal "JavaScriptTemplate <script>document.write('hello world')</script>", new_theme.template

    new_settings = create(:word_view_setting, theme_noun: new_theme)

    visit noun_path(create(:noun), word_view_setting_id: new_settings.id)
    assert_text "JavaScriptTemplate"
    assert_no_text "hello world"
  end

  test "with a different theme set, sets standard settings" do
    noun_theme = create(:theme, word_type: :noun, name: "Nomenkarte")
    verb_theme = create(:theme, word_type: :verb, name: "Verbenkarte")
    word_view_setting = create(:word_view_setting, theme_noun: noun_theme, theme_verb: verb_theme, owner: @admin)
    @admin.update!(word_view_setting:)

    refute_nil @admin.word_view_setting

    visit profile_path

    assert_text word_view_setting.name

    within ".ci-word-view-setting" do
      click_on I18n.t("actions.change")
    end

    select "", from: User.human_attribute_name(:word_view_setting)
    click_on t("helpers.submit.update")

    assert_current_path profile_path
    assert_nil @admin.reload.word_view_setting
  end

  test "with default theme set, sets other settings" do
    noun_theme = create(:theme, word_type: :noun, name: "Nomenkarte")
    verb_theme = create(:theme, word_type: :verb, name: "Verbenkarte")
    word_view_setting = create(:word_view_setting, theme_noun: noun_theme, theme_verb: verb_theme, owner: @admin)

    assert_nil @admin.word_view_setting

    visit profile_path

    assert_no_text word_view_setting.name

    within ".ci-word-view-setting" do
      click_on I18n.t("actions.change")
    end

    select word_view_setting.name, from: User.human_attribute_name(:word_view_setting)
    click_on t("helpers.submit.update")

    assert_current_path profile_path

    @admin.reload
    assert_equal word_view_setting, @admin.word_view_setting
  end

  test "renders the correct theme" do
    theme = create(:theme, word_type: :noun, name: "Nomenkarte", template: "CurrentTheme {{ meaning }}")
    word_view_setting = create(:word_view_setting, theme_noun: theme)
    noun = create(:noun, name: "Bauer", meaning: "Meine Bedeutung")

    assert_nil @admin.word_view_setting

    visit noun_path(noun)
    assert_text noun.name

    @admin.update!(word_view_setting:)

    assert_equal theme, @admin.reload.word_view_setting.theme_noun

    visit noun_path(noun)
    assert_no_text noun.name
    assert_text noun.meaning
  end

  test "always renders the default template for guests" do
    theme = create(:theme, word_type: :noun, name: "Nomenkarte", template: "CurrentTheme {{ meaning }}")
    word_view_setting = create(:word_view_setting, theme_noun: theme)
    noun = create(:noun, name: "Bauer", meaning: "Meine Bedeutung")

    @admin.update!(word_view_setting:)
    visit noun_path(noun)
    assert_no_text noun.name
    assert_text noun.meaning

    logout
    visit noun_path(noun)
    assert_text noun.name
  end

  test "uses the settings in the homepage URL" do
    theme = create(:theme, word_type: :noun, name: "Nomenkarte", template: "CurrentTheme {{ meaning }}")
    word_view_setting = create(:word_view_setting, theme_noun: theme)
    other_theme = create(:theme, word_type: :noun, name: "Neue Nomenkarte", template: "OtherTheme {{ meaning }}")
    other_word_view_setting = create(:word_view_setting, theme_noun: other_theme)
    noun = create(:noun, name: "Bauer", meaning: "Meine Bedeutung")

    @admin.update!(word_view_setting:)
    assert_equal word_view_setting, @admin.word_view_setting

    visit noun_path(noun)
    assert_text "CurrentTheme"

    visit "/seite/ansicht/#{other_word_view_setting.id}"
    assert_equal other_word_view_setting, @admin.reload.word_view_setting

    visit noun_path(noun)
    assert_text "OtherTheme"
  end

  test "uses the settings in the current page URL" do
    theme = create(:theme, word_type: :noun, name: "Nomenkarte", template: "CurrentTheme {{ meaning }}")
    word_view_setting = create(:word_view_setting, theme_noun: theme)
    other_theme = create(:theme, word_type: :noun, name: "Neue Nomenkarte", template: "OtherTheme {{ meaning }}")
    other_word_view_setting = create(:word_view_setting, theme_noun: other_theme)
    noun = create(:noun, name: "Bauer", meaning: "Meine Bedeutung")

    @admin.update!(word_view_setting:)
    assert_equal word_view_setting, @admin.word_view_setting

    visit noun_path(noun)
    assert_text "CurrentTheme"

    visit noun_path(noun, word_view_setting_id: other_word_view_setting.id)
    assert_text "OtherTheme"

    assert_equal other_word_view_setting, @admin.reload.word_view_setting
  end

  test "updates the theme for all users in a learning group" do
    learning_group = create(:learning_group)
    user1 = create(:guest)
    user2 = create(:guest)
    noun_theme = create(:theme, word_type: :noun)
    word_view_setting = create(:word_view_setting, theme_noun: noun_theme, owner: learning_group.owner)
    create(
      :learning_group_membership,
      user: user1,
      learning_group: learning_group,
      access: :granted
    )

    assert_nil learning_group.reload.word_view_setting
    assert_nil user1.word_view_setting&.theme_noun
    assert_nil user2.word_view_setting&.theme_noun

    visit learning_group_path(learning_group)
    assert_text user1.full_name
    assert_no_text user2.full_name

    click_on I18n.t("actions.edit")

    select word_view_setting.name, from: LearningGroup.human_attribute_name(:word_view_setting)
    click_on I18n.t("actions.save")

    assert_equal word_view_setting, learning_group.reload.word_view_setting
    assert_equal word_view_setting, user1.reload.word_view_setting
    assert_equal noun_theme, user1.reload.word_view_setting.theme_noun
    assert_nil user2.reload.word_view_setting
  end
end
