# frozen_string_literal: true

FactoryBot.define do
  factory :adjective do
    name { Faker::Adjective.positive }
  end
end
