source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 4.0.3"

gem "rails", "~> 8.1.0"
gem "activerecord-session_store"
gem "active_storage_svg_sanitizer"
gem "bootsnap", require: false
gem "cancancan"
gem "clamped"
gem "cologne_phonetics"
gem "csv"
gem "ostruct" # Ruby 4 dropped ostruct from default gems; filterrific still uses it
gem "device_detector"
gem "devise"
gem "devise-i18n"
gem "draper"
gem "easy_talk"
gem "enumerize"
gem "faraday"
gem "filterrific", "~> 5.2"
gem "friendly_id"
gem "good_job", "< 5"
gem "google-cloud-text_to_speech"
gem "haml"
gem "haml-rails"
gem "heroicon"
gem "humanize_boolean" # adds TrueClass/FalseClass#humanize, used by JSON views
gem "image_processing"
gem "importmap-rails"
gem "jbuilder"
gem "kaminari"
gem "langchainrb", require: "langchain"
gem "liquid"
gem "meta-tags"
gem "paper_trail"
gem "pg", "~> 1.5"
gem "propshaft"
gem "puma", "~> 6.6"
gem "rack-cors"
gem "rails-i18n", "~> 8.1"
gem "rb-gravatar"
gem "redis", "~> 5.3" # Use Redis for Action Cable
gem "route_downcaser"
gem "ruby-openai", "~> 8.1"
gem "ruby-vips"
gem "sanitize"
gem "scenic"
gem "simple_form"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "ttfunk"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "view_component"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener"
  gem "web-console"
  gem "foreman"
  gem "tidewave"
end

group :test do
  gem "capybara"
  gem "capybara-screenshot"
  gem "cuprite"
  gem "rspec-retry"
  gem "simplecov", require: false
  gem "webmock"
end

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
  gem "standardrb"
  gem "mina", "1.2.5"
end
