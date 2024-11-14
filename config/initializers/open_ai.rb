Rails.application.config.to_prepare do
  OpenAI.configuration.uri_base = if Rails.env.test?
    "https://ai.test"
  else
    ENV["OLLAMA_URL"]
  end
end
