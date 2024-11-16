# frozen_string_literal: true

FactoryBot.define do
  factory :word_import do
    name { "Katze" }
    topic { "Tiere" }
    word_type { "Noun" }
    state { "new" }
  end
end
