# frozen_string_literal: true

class CompoundPostconfixesController < ApplicationController
  load_and_authorize_resource

  def index
    @compound_postconfixes = @compound_postconfixes.order(:name).page(params[:page])
  end

  def show
    @words = @compound_postconfix.words.page(params[:page])
  end

  def new
  end

  def create
    if @compound_postconfix.save
      redirect_to @compound_postconfix, notice: t("notices.shared.created", name: @compound_postconfix.name, class_name: CompoundPostconfix.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @compound_postconfix.update(compound_postconfix_params)
      redirect_to @compound_postconfix, notice: t("notices.shared.updated", name: @compound_postconfix.name, class_name: CompoundPostconfix.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @compound_postconfix.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @compound_postconfix.name, class_name: CompoundPostconfix.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @compound_postconfix.name)}
    end

    redirect_to compound_postconfixes_url, notice
  end

  private

  def compound_postconfix_params
    params.require(:compound_postconfix).permit(
      :name
    )
  end
end
