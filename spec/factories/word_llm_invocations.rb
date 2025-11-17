# frozen_string_literal: true

FactoryBot.define do
  factory :word_llm_invocation do
    key { "Noun#123" }
    invocation_type { "enrichment" }
    state { "invoked" }
    error { nil }
    completed_at { nil }
  end
end
