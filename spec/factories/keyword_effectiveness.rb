FactoryBot.define do
  factory :keyword_effectiveness do
    association :word, factory: :noun
    association :keyword, factory: :noun
    pick_id { SecureRandom.uuid }
    round_id { SecureRandom.uuid }
    keyword_position { 1 }
    revealed_at { 30.seconds.ago }
    picked_at { 5.seconds.ago }
    led_to_correct { true }
  end
end
