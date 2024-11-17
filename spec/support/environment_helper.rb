# frozen_string_literal: true

# Taken from https://stackoverflow.com/a/41470763/1023963
module EnvironmentHelper
  def with_environment(replacement_env)
    original_env = ENV.to_hash
    ENV.update(replacement_env)

    yield
  ensure
    ENV.replace(original_env)
  end
end
