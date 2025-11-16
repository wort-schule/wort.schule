# frozen_string_literal: true

class CompoundInterfixesController < CrudResourceController
  private

  def permitted_attributes
    [:name]
  end
end
