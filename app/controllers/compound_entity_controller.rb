# frozen_string_literal: true

class CompoundEntityController < ApplicationController
  load_and_authorize_resource

  def index
    instance_variable_set(collection_instance_variable, collection.order(:name).page(params[:page]))
  end

  def show
    @words = resource.words.page(params[:page])
  end

  def new
  end

  def create
    if resource.save
      redirect_to resource, notice: t("notices.shared.created", name: resource.name, class_name: model_class.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if resource.update(resource_params)
      redirect_to resource, notice: t("notices.shared.updated", name: resource.name, class_name: model_class.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = resource.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: resource.name, class_name: model_class.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: resource.name)}
    end

    redirect_to collection_url, notice
  end

  private

  def resource
    instance_variable_get(resource_instance_variable)
  end

  def collection
    instance_variable_get(collection_instance_variable)
  end

  def resource_params
    params.require(resource_name).permit(:name)
  end

  def resource_name
    controller_name.singularize
  end

  def resource_instance_variable
    "@#{resource_name}"
  end

  def collection_instance_variable
    "@#{controller_name}"
  end

  def collection_url
    send(:"#{controller_name}_url")
  end

  def model_class
    controller_name.classify.constantize
  end
end
