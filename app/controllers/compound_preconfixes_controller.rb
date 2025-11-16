# frozen_string_literal: true

class CompoundPreconfixesController < CrudResourceController
  private

  def permitted_attributes
    [:name]
  end
end
