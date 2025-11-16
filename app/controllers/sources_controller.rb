# frozen_string_literal: true

class SourcesController < CrudResourceController
  private

  def permitted_attributes
    [:name, :author, :licence, :source_url, :comment, :visible]
  end
end
