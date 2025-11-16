# frozen_string_literal: true

class PostfixesController < CrudResourceController
  private

  def permitted_attributes
    [:name]
  end
end
