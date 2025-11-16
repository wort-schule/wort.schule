# frozen_string_literal: true

class CompoundPhonemreductionsController < CrudResourceController
  private

  def permitted_attributes
    [:name]
  end
end
