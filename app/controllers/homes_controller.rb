# frozen_string_literal: true

class HomesController < PublicController
  include WordHelper

  def show
    @filterrific = initialize_filterrific(
      Word,
      params[:filterrific] || {}
    ) or return

    @words = if params.dig(:filterrific, :filter_home).blank?
      @counts = {
        all: 0
      }

      Word.none
    else
      @counts = {
        all: word_count_for("")
      }

      @filterrific.find.page(params[:page]).per(8)
    end
  end
end
