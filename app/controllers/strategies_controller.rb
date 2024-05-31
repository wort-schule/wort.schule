# frozen_string_literal: true

class StrategiesController < ApplicationController
  load_and_authorize_resource

  def index
    @strategies = @strategies.order(:name).page(params[:page])
  end

  def show
    @words = @strategy.words.ordered_lexigraphically.page(params[:page])
  end

  def new
  end

  def create
    if @strategy.save
      redirect_to @strategy, notice: t("notices.shared.created", name: @strategy.name, class_name: Strategy.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @strategy.update(strategy_params)
      redirect_to @strategy, notice: t("notices.shared.updated", name: @strategy.name, class_name: Strategy.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @strategy.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @strategy.name, class_name: Strategy.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @strategy.name)}
    end

    redirect_to strategies_url, notice
  end

  private

  def strategy_params
    params.require(:strategy).permit(
      :name, :description, :fresch_symbol
    )
  end
end
