# frozen_string_literal: true

require_relative "../i18n_helpers"

module Flows
  class SiteFlow
    include RSpec::Matchers
    include Capybara::DSL
    include FactoryBot::Syntax::Methods
    include Rails.application.routes.url_helpers
    include Support::I18nHelpers
  end
end
