Rails.application.config.to_prepare do
  OpenAI.configuration.uri_base = ENV["OLLAMA_URL"]
end
