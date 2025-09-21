# frozen_string_literal: true

class NounsController < WordTypeController
  def by_genus
    nouns = Noun.by_genus(params[:genus]).ordered_lexigraphically.map do |noun|
      {
        text: noun.name,
        value: noun.id
      }
    end

    render json: nouns
  end

  private

  def resource_params
    noun_params
  end

  def noun_params
    params.require(:noun).permit(
      :plural,
      :genus_id,
      :singularetantum,
      :pluraletantum,
      :case_1_singular,
      :case_1_plural,
      :case_2_singular,
      :case_2_plural,
      :case_3_singular,
      :case_3_plural,
      :case_4_singular,
      :case_4_plural,
      :genus_neuter_id,
      :genus_masculine_id,
      :genus_feminine_id,
      *Word::ATTRIBUTES
    )
  end
end
