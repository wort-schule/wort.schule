# frozen_string_literal: true

module Themeable
  extend ActiveSupport::Concern

  included do
    def theme
      @theme = Theme.accessible_by(current_ability).find(params[:theme_id])
      @word = instance_variable_get(:"@#{params[:controller].singularize}")
    end
  end
end
