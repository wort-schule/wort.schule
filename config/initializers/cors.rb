# Be sure to restart your server when you modify this file.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Public API - open to all origins
  allow do
    origins "*"

    resource "/api/*",
      headers: :any,
      methods: [:get, :head, :options],
      credentials: false
  end

  # ActiveStorage assets for known frontends
  allow do
    origins "spiel.wort.schule", "localhost:4000", "http://localhost:4000"

    resource "/rails/active_storage/*",
      headers: :any,
      methods: [:get, :head, :options],
      credentials: false

    resource "/uploads/*",
      headers: :any,
      methods: [:get, :head, :options],
      credentials: false
  end
end
