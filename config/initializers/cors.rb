# Be sure to restart your server when you modify this file.

# Allow CORS requests for images and other assets from spiel.wort.schule and localhost:4000
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "spiel.wort.schule", "localhost:4000", "http://localhost:4000"

    resource "/rails/active_storage/*",
      headers: :any,
      methods: [:get, :head, :options],
      credentials: false

    # Also allow access to any uploaded images/assets
    resource "/uploads/*",
      headers: :any,
      methods: [:get, :head, :options],
      credentials: false
  end
end
