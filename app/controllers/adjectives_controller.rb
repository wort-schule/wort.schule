# frozen_string_literal: true

class AdjectivesController < WordTypeController
  private

  def resource_params
    adjective_params
  end

  def adjective_params
    params.require(:adjective).permit(
      :comparative,
      :superlative,
      :absolute,
      :irregular_comparison,
      :irregular_declination,
      *Word::ATTRIBUTES
    )
  end
end
