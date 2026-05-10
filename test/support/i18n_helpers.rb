# frozen_string_literal: true

module Support
  module I18nHelpers
    def t(key, **)
      I18n.t(key, **)
    end
  end
end
