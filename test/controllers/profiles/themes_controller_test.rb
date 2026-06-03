# frozen_string_literal: true

require "test_helper"

module Profiles
  class ThemesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user)
      sign_in @user
    end

    test "#index renders for a user who has a word view setting" do
      setting = create(:word_view_setting, owner: @user)
      @user.update!(word_view_setting: setting)

      get profile_themes_path(word_type: "noun")

      assert_response :success
    end

    test "#index renders for a user without a word view setting" do
      assert_nil @user.word_view_setting

      get profile_themes_path(word_type: "noun")

      assert_response :success
    end

    test "#update stores the chosen theme on the user's word view setting" do
      setting = create(:word_view_setting, owner: @user)
      @user.update!(word_view_setting: setting)
      theme = create(:theme, word_type: :noun, visibility: :public)

      patch profile_theme_path(theme, word_type: "noun")

      assert_redirected_to profile_path
      assert_equal theme, setting.reload.theme_noun
    end

    test "#update creates a word view setting on the fly when the user has none" do
      assert_nil @user.word_view_setting
      theme = create(:theme, word_type: :noun, visibility: :public)

      assert_difference -> { WordViewSetting.count }, 1 do
        patch profile_theme_path(theme, word_type: "noun")
      end

      assert_redirected_to profile_path
      setting = @user.reload.word_view_setting
      assert_not_nil setting
      assert_equal @user, setting.owner
      assert_equal theme, setting.theme_noun
    end

    test "#update can reset the theme to the standard with id 0" do
      theme = create(:theme, word_type: :noun)
      setting = create(:word_view_setting, owner: @user, theme_noun: theme)
      @user.update!(word_view_setting: setting)

      patch profile_theme_path(0, word_type: "noun")

      assert_redirected_to profile_path
      assert_nil setting.reload.theme_noun
    end
  end
end
