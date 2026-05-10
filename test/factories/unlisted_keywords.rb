# frozen_string_literal: true

FactoryBot.define do
  factory :unlisted_keyword do
    association :word, factory: :noun
    association :word_import
    new_word { nil }
    state { "new" }
  end
end
