# frozen_string_literal: true

class SearchesController < PublicController
  include ListAddable

  def show
    @filterrific = initialize_filterrific(
      Word,
      params[:filterrific]
    ) or return

    @words = @filterrific
      .find
      .ordered_lexigraphically
      .page(params[:page])
  end
end
