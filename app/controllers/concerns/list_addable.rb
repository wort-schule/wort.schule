# frozen_string_literal: true

module ListAddable
  extend ActiveSupport::Concern

  included do
    def add_to_list
      list = List.accessible_by(current_ability).find(params[:list_id])
      word_type = params.dig(:filterrific, :filter_type) || params[:controller].singularize.capitalize.clamped(%w[Noun Verb Adjective])
      @filterrific = initialize_filterrific(
        Word,
        (params[:filterrific] || {}).merge(filter_type: word_type)
      ) or return
      list.words << @filterrific.find

      render "filters/add_to_list"
    end
  end
end
