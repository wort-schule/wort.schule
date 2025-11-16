# frozen_string_literal: true

class PhenomenonsController < CrudResourceController
  private

  def permitted_attributes
    [:name, :description]
  end
end
