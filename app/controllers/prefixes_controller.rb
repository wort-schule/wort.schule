# frozen_string_literal: true

class PrefixesController < ApplicationController
  load_and_authorize_resource

  def index
    @prefixes = @prefixes.order(:name).page(params[:page])
  end

  def show
    @words = @prefix.words.ordered_lexigraphically.page(params[:page])
  end

  def new
  end

  def create
    if @prefix.save
      redirect_to @prefix, notice: t("notices.shared.created", name: @prefix.name, class_name: Prefix.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @prefix.update(prefix_params)
      redirect_to @prefix, notice: t("notices.shared.updated", name: @prefix.name, class_name: Prefix.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @prefix.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @prefix.name, class_name: Prefix.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @prefix.name)}
    end

    redirect_to prefixes_url, notice
  end

  private

  def prefix_params
    params.require(:prefix).permit(
      :name, :prefix_type, :separable, :inseparable
    )
  end
end
