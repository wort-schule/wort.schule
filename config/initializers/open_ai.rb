Rails.application.config.to_prepare do
  OpenAI.configuration.uri_base = if Rails.env.test?
    "https://ai.test"
  else
    ENV["OLLAMA_URL"].presence || "http://localhost:11434/v1"
  end
end
