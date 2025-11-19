# frozen_string_literal: true

class ThemesController < ApplicationController
  load_and_authorize_resource

  def index
    @themes = @themes.order(:name).page(params[:page])
  end

  def show
  end

  def new
    if params[:theme_id].present?
      @template_theme = Theme.accessible_by(current_ability).find(params[:theme_id])

      @theme.name = I18n.t("themes.new.copy_of", name: @template_theme.name)
      @theme.description = @template_theme.description
      @theme.template = @template_theme.template
      @theme.word_type = @template_theme.word_type
    end
  end

  def create
    @theme.user = current_user

    if @theme.save
      redirect_to @theme, notice: t("notices.shared.created", name: @theme.name, class_name: Theme.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @theme.update(theme_params)
      redirect_to @theme, notice: t("notices.shared.updated", name: @theme.name, class_name: Theme.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @theme.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @theme.name, class_name: Theme.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @theme.name)}
    end

    redirect_to themes_url, notice
  end

  private

  def page_title
    case action_name
    when "index"
      t("themes.index.title")
    when "show"
      @theme.name
    when "new"
      t("themes.new.title")
    when "edit"
      t("themes.edit.title")
    end
  end
  helper_method :page_title

  def theme_params
    params.require(:theme).permit(
      :name, :description, :word_type, :template, :visibility
    )
  end
end
