# frozen_string_literal: true

class VerbsController < WordTypeController
  private

  def resource_params
    verb_params
  end

  def verb_params
    params.require(:verb).permit(
      :subjectless,
      :strong,
      :imperative_singular,
      :imperative_plural,
      :participle,
      :past_participle,
      :perfect_haben,
      :perfect_sein,
      :present_singular_1,
      :present_singular_2,
      :present_singular_3,
      :present_plural_1,
      :present_plural_2,
      :present_plural_3,
      :past_singular_1,
      :past_singular_2,
      :past_singular_3,
      :past_plural_1,
      :past_plural_2,
      :past_plural_3,
      *Word::ATTRIBUTES
    )
  end
end
