# frozen_string_literal: true

module Profiles
  class ThemesController < ApplicationController
    load_and_authorize_resource only: :index
    authorize_resource only: :update

    helper_method :word_type

    def index
      @themes = @themes.order(:name).where(word_type:).page(params[:page])
      @active_theme = current_user.word_view_setting&.public_send(theme_attribute)
    end

    def update
      word_view_setting.update!(theme_attribute => chosen_theme)

      redirect_to profile_path
    end

    private

    # The per-word-type themes used to be columns on User; they now live on the
    # user's WordViewSetting. A user may not have one yet, so create and link one
    # the first time they pick a theme so the preference has somewhere to live.
    def word_view_setting
      current_user.word_view_setting || create_word_view_setting
    end

    def create_word_view_setting
      setting = WordViewSetting.create!(
        name: t("profiles.themes.update.default_word_view_setting_name", name: current_user.to_s),
        owner: current_user
      )
      current_user.update!(word_view_setting: setting)
      setting
    end

    def chosen_theme
      if params[:id] == "0"
        nil
      else
        Theme.accessible_by(current_ability).find(params[:id])
      end
    end

    def word_type
      params[:word_type]
        &.downcase
        &.to_sym
        &.clamped(Theme::WORD_TYPES).presence || Theme::WORD_TYPES.first
    end

    def theme_attribute
      "theme_#{word_type}"
    end
  end
end
