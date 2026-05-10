# frozen_string_literal: true

FactoryBot.define do
  factory :word do
    name { Faker::Verb.base }
  end
end
