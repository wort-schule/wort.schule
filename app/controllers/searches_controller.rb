# frozen_string_literal: true

class SearchesController < PublicController
  def show
    @filterrific = initialize_filterrific(
      word_type,
      params[:filterrific]
    ) or return

    @words = @filterrific
      .find
      .ordered_lexigraphically
      .page(params[:page])
  end

  private

  def word_type
    allowed_types = %w[Noun Verb Adjective]
    provided_type = params.dig(:filterrific, :filter_type)

    if allowed_types.include?(provided_type)
      provided_type.constantize
    else
      Noun
    end
  end
end
