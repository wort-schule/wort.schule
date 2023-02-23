# frozen_string_literal: true

class HomesController < PublicController
  def show
    @filterrific = initialize_filterrific(
      Word,
      params[:filterrific] || {}
    ) or return

    @words = if params.dig(:filterrific, :filter_home).blank?
      Word.none
    else
      @filterrific.find
    end

    @words = @words.page(params[:page]).per(8)
  end
end
