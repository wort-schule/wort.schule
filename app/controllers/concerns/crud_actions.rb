# frozen_string_literal: true

# Provides common CRUD action implementations for controllers.
# Can be included in controllers that need standard CRUD operations
# but cannot inherit from CrudResourceController.
#
# Usage:
#   class TopicsController < PublicController
#     include CrudActions
#     load_and_authorize_resource
#
#     private
#
#     def permitted_attributes
#       [:name, :image]
#     end
#   end
module CrudActions
  extend ActiveSupport::Concern

  included do
    # Override these methods in the including controller if needed
    helper_method :page_title
  end

  def index
    instance_variable_set(:"@#{controller_name}", resources.order(:name).page(params[:page]))
  end

  def show
    @words = resource.words.ordered_lexigraphically.page(params[:page]) if resource.respond_to?(:words)
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

  def remove_image
    resource.image.purge if resource.image.attached?
    redirect_to resource
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
    params.require(resource_name).permit(permitted_attributes)
  end

  def permitted_attributes
    raise NotImplementedError, "#{self.class} must implement #permitted_attributes"
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

  def page_title
    case action_name
    when "index"
      resource_class.model_name.human(count: 2)
    when "show"
      resource.name
    when "new"
      t("#{controller_name}.new.title")
    when "edit"
      t("#{controller_name}.edit.title")
    end
  end
end
