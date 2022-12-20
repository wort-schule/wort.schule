source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.0"

gem "rails", "~> 7.0.4"
gem "active_record_extended"
gem "active_storage_svg_sanitizer"
gem "bootsnap", require: false
gem "cancancan"
gem "clamped"
gem "cologne_phonetics"
gem "country_select"
gem "device_detector"
gem "devise"
gem "devise-i18n"
gem "draper"
gem "enumerize"
gem "filterrific", github: "metikular/filterrific", branch: "fix/nested-array"
gem "friendly_id"
gem "good_job"
gem "google-cloud-text_to_speech"
gem "haml"
gem "haml-rails"
gem "heroicon"
gem "humanize_boolean"
gem "image_processing"
gem "importmap-rails"
gem "jbuilder"
gem "kaminari"
gem "liquid"
gem "meta-tags"
gem "paper_trail"
gem "pg", "~> 1.4"
gem "phony_rails"
gem "propshaft"
gem "puma", "~> 6.0"
gem "rails-i18n"
gem "rb-gravatar"
gem "redis", "~> 5.0" # Use Redis for Action Cable
gem "route_downcaser"
gem "ruby-vips"
gem "sanitize"
gem "simple_form"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "validate_url"
gem "view_component"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener"
  gem "web-console"
  gem "foreman"
end

group :test do
  gem "capybara"
  gem "capybara-screenshot"
  gem "cuprite"
  gem "faker"
  gem "simplecov", require: false
end

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot"
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "standardrb"
  gem "mina", "1.2.4"
end

group :production do
  gem "unicorn"
end
