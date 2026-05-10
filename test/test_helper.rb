# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rails/test_help"
require "minitest/mock"
require "webmock/minitest"

WebMock.disable_net_connect!(allow: ["127.0.0.1", "localhost"])

Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include Support::I18nHelpers
  include Support::ActionMailerHelpers
  include EnvironmentHelper
  include ActionView::RecordIdentifier
  include ActiveJob::TestHelper
  include ActionDispatch::TestProcess::FixtureFile
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

class ApplicationViewComponentTestCase < ActiveSupport::TestCase
  include ViewComponent::TestHelpers
  include Capybara::Minitest::Assertions

  def page
    Capybara.string(rendered_content)
  end
end
