# frozen_string_literal: true

module Support
  module I18nHelpers
    def t(key, **options)
      I18n.t(key, **options)
    end
  end
end
