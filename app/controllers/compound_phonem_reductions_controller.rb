# frozen_string_literal: true

class CompoundPhonemReductionsController < CrudResourceController
  private

  def permitted_attributes
    [:name]
  end
end
