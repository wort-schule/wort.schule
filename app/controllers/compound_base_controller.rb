# frozen_string_literal: true

class CompoundBaseController < ApplicationController
  load_and_authorize_resource

  def index
    instance_variable_set(:"@#{controller_name}", resources.order(:name).page(params[:page]))
  end

  def show
    @words = resource.words.page(params[:page])
  end

  def new
  end

  def create
    if resource.save
      redirect_to resource, notice: create_notice
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if resource.update(resource_params)
      redirect_to resource, notice: update_notice
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = resource.destroy
    notice = if destroyed
      {notice: destroy_notice}
    else
      {alert: destroy_alert}
    end

    redirect_to url_for(action: :index), notice
  end

  private

  def resource
    instance_variable_get(:"@#{resource_name}")
  end

  def resources
    instance_variable_get(:"@#{controller_name}")
  end

  def resource_name
    controller_name.singularize
  end

  def resource_class
    resource_name.camelize.constantize
  end

  def resource_params
    params.require(resource_name).permit(:name)
  end

  def create_notice
    t("notices.shared.created", name: resource.name, class_name: resource_class.model_name.human)
  end

  def update_notice
    t("notices.shared.updated", name: resource.name, class_name: resource_class.model_name.human)
  end

  def destroy_notice
    t("notices.shared.destroyed", name: resource.name, class_name: resource_class.model_name.human)
  end

  def destroy_alert
    t("alerts.shared.destroyed", name: resource.name)
  end
end
