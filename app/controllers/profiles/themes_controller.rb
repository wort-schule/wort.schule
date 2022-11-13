# frozen_string_literal: true

module Profiles
  class ThemesController < ApplicationController
    load_and_authorize_resource only: :index
    authorize_resource only: :update

    helper_method :word_type

    def index
      @themes = @themes.order(:name).where(word_type:).page(params[:page])
      @active_theme = current_user.public_send(theme_attribute)
    end

    def update
      current_user.update!(theme_attribute => chosen_theme)

      redirect_to profile_path
    end

    private

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
        &.clamped(%w[noun verb adjective function_word]).presence || "noun"
    end

    def theme_attribute
      "theme_#{word_type}"
    end
  end
end
