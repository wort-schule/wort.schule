# frozen_string_literal: true

class WordViewSettingsController < ApplicationController
  load_and_authorize_resource

  def index
    @word_view_settings = @word_view_settings.order(:name).page(params[:page])
  end

  def show
  end

  def new
  end

  def create
    @word_view_setting.owner = current_user

    if @word_view_setting.save
      redirect_to @word_view_setting, notice: t("notices.shared.created", name: @word_view_setting.name, class_name: WordViewSetting.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @word_view_setting.update(word_view_setting_params)
      redirect_to @word_view_setting, notice: t("notices.shared.updated", name: @word_view_setting.name, class_name: WordViewSetting.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    notice = if @word_view_setting.destroy
      {notice: t("notices.shared.destroyed", name: @word_view_setting.name, class_name: WordViewSetting.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @word_view_setting.name)}
    end

    redirect_to word_view_settings_url, notice
  end

  private

  def word_view_setting_params
    params.require(:word_view_setting).permit(
      :name,
      :visibility,
      :theme_noun_id,
      :theme_verb_id,
      :theme_adjective_id,
      :theme_function_word_id,
      :font,
      :show_house,
      :show_syllable_arcs,
      :color_syllables,
      :show_horizontal_lines,
      :show_montessori_symbols,
      :show_fresch_symbols,
      :show_gender_symbols
    )
  end
end
