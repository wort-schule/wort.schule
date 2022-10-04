# frozen_string_literal: true

FactoryBot.define do
  factory :example_sentence do
    sentence { Faker::Lorem.sentence }
    word
  end
end
