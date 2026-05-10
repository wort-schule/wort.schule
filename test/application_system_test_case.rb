# frozen_string_literal: true

require "test_helper"
require "capybara/cuprite"
require "capybara/minitest"
require "capybara-screenshot/minitest"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app,
    window_size: [1200, 800],
    js_errors: true,
    timeout: 10,
    process_timeout: 30)
end

Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 5
Capybara.asset_host = "http://localhost:3000"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite

  include Warden::Test::Helpers
  include Devise::Test::IntegrationHelpers
  include CupriteHelpers
  include OpenGraphAssertions

  setup do
    Warden.test_mode!
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    Warden.test_reset!
    Capybara.reset_sessions!
  end
end
