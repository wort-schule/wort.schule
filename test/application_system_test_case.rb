# frozen_string_literal: true

require "test_helper"
require "capybara/cuprite"
require "capybara/minitest"
require "capybara-screenshot/minitest"

Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 5
Capybara.asset_host = "http://localhost:3000"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Configure Cuprite through driven_by, not a standalone
  # Capybara.register_driver(:cuprite) block. Rails treats :cuprite as a
  # "registerable" driver, so driven_by re-registers it on the first system
  # test and silently overwrites any standalone registration. Options passed
  # here are the ones Rails actually applies.
  #
  # process_timeout: 30 gives Chrome a generous budget to produce its websocket
  # URL on a cold, loaded CI runner. With the old (overwritten) config the
  # effective value was Ferrum's 10s default, which the first system test in a
  # run could exceed -> Ferrum::ProcessTimeoutError.
  driven_by :cuprite, screen_size: [1200, 800], options: {
    timeout: 10,
    process_timeout: 30
  }

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
