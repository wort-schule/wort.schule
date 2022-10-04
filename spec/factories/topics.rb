# frozen_string_literal: true

FactoryBot.define do
  factory :topic do
    name { Faker::IndustrySegments.sector }
  end
end
