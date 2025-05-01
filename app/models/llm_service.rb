# frozen_string_literal: true

class LlmService < ApplicationRecord
  extend Enumerize

  enumerize :service_klass, in: %w[Ollama AI21 Anthropic AwsBedrock Azure Cohere GoogleGemini GoogleVertexAI HuggingFace LlamaCpp MistralAI OpenAI].sort

  validates :name, presence: true
  validates :service_klass, presence: true
  validates :endpoint, presence: true, if: ->(model) { model.service_klass == "Ollama" }
  validates :api_key, presence: true, if: ->(model) { model.service_klass != "Ollama" }
  validates :model, presence: true

  validate :only_one_active

  def self.active
    find_by(active: true)
  end

  def client(options = {})
    "Langchain::LLM::#{service_klass}"
      .constantize
      .new(
        url: endpoint,
        api_key: api_key,
        **options
      )
  end

  private

  def only_one_active
    if LlmService.where(active: true).count > 1
      errors.add(:active, :invalid)
    end
  end
end
