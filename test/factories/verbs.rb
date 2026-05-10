# frozen_string_literal: true

FactoryBot.define do
  factory :verb do
    name { Faker::Verb.base }
  end
end
