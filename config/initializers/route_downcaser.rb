RouteDowncaser.configuration do |config|
  # Use 301 to redirect to downcased URL
  config.redirect = true

  # We only want to redirect word URLs, i.e. URLs not containing a slash (`/`)
  # anywhere but the beginning
  config.exclude_patterns = [
    /^\/.*\/+/i
  ]
end
