# frozen_string_literal: true

class ThemesController < ApplicationController
  include CrudActions

  load_and_authorize_resource

  def new
    return if params[:theme_id].blank?

    @template_theme = Theme.accessible_by(current_ability).find(params[:theme_id])
    @theme.assign_attributes(
      name: I18n.t("themes.new.copy_of", name: @template_theme.name),
      description: @template_theme.description,
      template: @template_theme.template,
      word_type: @template_theme.word_type
    )
  end

  def create
    @theme.user = current_user
    super
  end

  private

  def permitted_attributes
    [:name, :description, :word_type, :template, :visibility]
  end
end
