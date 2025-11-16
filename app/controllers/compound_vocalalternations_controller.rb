# frozen_string_literal: true

class CompoundVocalalternationsController < CrudResourceController
  private

  def permitted_attributes
    [:name]
  end
end
