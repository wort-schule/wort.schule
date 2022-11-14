# frozen_string_literal: true

FactoryBot.define do
  factory :list do
    name { Faker::Company.name }
    user
  end
end
