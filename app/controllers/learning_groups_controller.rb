# frozen_string_literal: true

class LearningGroupsController < CrudResourceController
  # Override create to set the owner
  def create
    resource.owner = current_user
    super
  end

  private

  def permitted_attributes
    [:name, :user_id, :word_view_setting_id]
  end
end
