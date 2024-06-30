# frozen_string_literal: true

class HierarchiesController < ApplicationController
  load_and_authorize_resource

  def index
    @hierarchies = @hierarchies.order(:name).page(params[:page])
  end

  def show
    @words = @hierarchy.words.ordered_lexigraphically.page(params[:page])
  end

  def new
  end

  def create
    if @hierarchy.save
      redirect_to @hierarchy, notice: t("notices.shared.created", name: @hierarchy.name, class_name: Hierarchy.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @hierarchy.update(hierarchy_params)
      redirect_to @hierarchy, notice: t("notices.shared.updated", name: @hierarchy.name, class_name: Hierarchy.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @hierarchy.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @hierarchy.name, class_name: Hierarchy.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @hierarchy.name)}
    end

    redirect_to hierarchies_url, notice
  end

  private

  def hierarchy_params
    params.require(:hierarchy).permit(
      :name, :top_hierarchy_id, :image
    )
  end
end
