# frozen_string_literal: true

class CompoundPostconfixesController < CrudResourceController
  private

  def permitted_attributes
    [:name]
  end
end
