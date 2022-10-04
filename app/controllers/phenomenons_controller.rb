# frozen_string_literal: true

class PhenomenonsController < ApplicationController
  load_and_authorize_resource

  def index
    @phenomenons = @phenomenons.order(:name).page(params[:page])
  end

  def show
    @words = @phenomenon.words.ordered_lexigraphically.page(params[:page])
  end

  def new
  end

  def create
    if @phenomenon.save
      redirect_to @phenomenon, notice: t("notices.shared.created", name: @phenomenon.name, class_name: Phenomenon.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @phenomenon.update(phenomenon_params)
      redirect_to @phenomenon, notice: t("notices.shared.updated", name: @phenomenon.name, class_name: Phenomenon.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @phenomenon.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @phenomenon.name, class_name: Phenomenon.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @phenomenon.name)}
    end

    redirect_to phenomenons_url, notice
  end

  private

  def phenomenon_params
    params.require(:phenomenon).permit(
      :name, :description
    )
  end
end
