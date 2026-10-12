# frozen_string_literal: true

require "test_helper"

# The test environment uses Action Cable's in-memory "test" adapter, so the
# suite never loads the Redis adapter that development and production rely on.
# Loading it here catches a gem update that the adapter cannot work with (for
# example a "redis" version outside the range Rails allows) before it ships.
class CableAdapterTest < ActiveSupport::TestCase
  %w[development production].each do |environment|
    test "the #{environment} Action Cable adapter loads" do
      configuration = ActionCable::Server::Configuration.new
      configuration.cable = Rails.application.config_for(:cable, env: environment)

      assert_equal "redis", configuration.cable[:adapter]
      assert_equal ActionCable::SubscriptionAdapter::Redis, configuration.pubsub_adapter
    end
  end
end
