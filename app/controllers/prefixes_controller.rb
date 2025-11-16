# frozen_string_literal: true

class PrefixesController < CrudResourceController
  private

  def permitted_attributes
    [:name, :prefix_type, :separable, :inseparable]
  end
end
