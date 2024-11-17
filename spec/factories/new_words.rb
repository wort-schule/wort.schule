FactoryBot.define do
  factory :new_word do
    name { "Katzen" }
    topic { "Tiere" }
    word_type { "Noun" }
    llm_name { "Katze" }
    llm_topic { "Tiere" }
    state { "waiting_for_review" }
  end
end
