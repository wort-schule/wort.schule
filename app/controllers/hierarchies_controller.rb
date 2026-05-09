# frozen_string_literal: true

class HierarchiesController < PublicController
  include CrudActions

  load_and_authorize_resource

  def index
    super
    @show_children = ActiveRecord::Type::Boolean.new.cast(params[:show_children])
    @hierarchies = @hierarchies.where(parent: nil) unless @show_children
  end

  private

  def permitted_attributes
    [:name, :top_hierarchy_id, :image]
  end
end
