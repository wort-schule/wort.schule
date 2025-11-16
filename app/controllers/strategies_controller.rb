# frozen_string_literal: true

class StrategiesController < CrudResourceController
  private

  def permitted_attributes
    [:name, :description, :fresch_symbol]
  end
end
