# frozen_string_literal: true

# Note: Inherits from PublicController instead of CrudResourceController
# because topics are publicly accessible
class TopicsController < PublicController
  include CrudActions
  load_and_authorize_resource

  private

  def permitted_attributes
    [:name, :image]
  end
end
