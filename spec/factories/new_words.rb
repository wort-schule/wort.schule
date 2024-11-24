# frozen_string_literal: true

FactoryBot.define do
  factory :new_word do
    change_group
    name { "Katzen" }
    topic { "Tiere" }
    word_type { "Noun" }
    llm_name { "Katze" }
    llm_topic { "Haustiere" }
  end
end
