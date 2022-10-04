# frozen_string_literal: true

module Support
  module I18nHelpers
    def t(args)
      I18n.t(args)
    end
  end
end
