# frozen_string_literal: true

require "application_system_test_case"

class WordViewSettingsCrudTest < ApplicationSystemTestCase
  extend CrudTests

  crud_tests_for WordViewSetting
end

class WordViewSettingsTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, role: "Admin")
    @lecturer = create(:user, role: "Lecturer")
    @public_word_view_setting = create(:word_view_setting, owner: @admin, visibility: :public)
    @private_word_view_setting_of_admin = create(:word_view_setting, owner: @admin, visibility: :private)
    @private_word_view_setting_of_lecturer = create(:word_view_setting, owner: @lecturer, visibility: :private)
  end

  test "as an admin, shows private word view settings from other users" do
    login_as @admin
    visit word_view_settings_path

    assert_text @public_word_view_setting.name
    assert_text @private_word_view_setting_of_admin.name
    assert_text @private_word_view_setting_of_lecturer.name
  end

  test "as a lecturer, shows only my own private word view settings" do
    login_as @lecturer
    visit word_view_settings_path

    assert_text @public_word_view_setting.name
    assert_no_text @private_word_view_setting_of_admin.name
    assert_text @private_word_view_setting_of_lecturer.name
  end
end
