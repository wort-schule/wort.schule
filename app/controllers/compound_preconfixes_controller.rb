# frozen_string_literal: true

class CompoundPreconfixesController < ApplicationController
  load_and_authorize_resource

  def index
    @compound_preconfixes = @compound_preconfixes.order(:name).page(params[:page])
  end

  def show
    @words = @compound_preconfix.words.page(params[:page])
  end

  def new
  end

  def create
    if @compound_preconfix.save
      redirect_to @compound_preconfix, notice: t("notices.shared.created", name: @compound_preconfix.name, class_name: CompoundPreconfix.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @compound_preconfix.update(compound_preconfix_params)
      redirect_to @compound_preconfix, notice: t("notices.shared.updated", name: @compound_preconfix.name, class_name: CompoundPreconfix.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @compound_preconfix.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @compound_preconfix.name, class_name: CompoundPreconfix.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @compound_preconfix.name)}
    end

    redirect_to compound_preconfixes_url, notice
  end

  private

  def compound_preconfix_params
    params.require(:compound_preconfix).permit(
      :name
    )
  end
end
