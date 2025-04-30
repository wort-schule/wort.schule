# frozen_string_literal: true

FactoryBot.define do
  factory :llm_service do
    name { "Ollama" }
    service_klass { "Ollama" }
    endpoint { "https://ai.test" }
    api_key { nil }
    model { "llama3.1" }
    active { true }
  end
end
