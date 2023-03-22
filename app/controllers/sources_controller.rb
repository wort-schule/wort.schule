# frozen_string_literal: true

class SourcesController < ApplicationController
  load_and_authorize_resource

  def index
    @sources = @sources.order(:name).page(params[:page])
  end

  def show
    @words = @source.words.ordered_lexigraphically.page(params[:page])
  end

  def new
  end

  def create
    if @source.save
      redirect_to @source, notice: t("notices.sources.created", name: @source.name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @source.update(source_params)
      redirect_to @source, notice: t("notices.sources.updated", name: @source.name)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @source.destroy
    notice = if destroyed
      {notice: t("notices.sources.destroyed", name: @source.name)}
    else
      {alert: t("alerts.sources.destroyed", name: @source.name)}
    end

    redirect_to sources_path, notice
  end

  private

  def source_params
    params.require(:source).permit(
      :name,
      :author,
      :licence,
      :source_url,
      :comment,
      :visible
    )
  end
end
