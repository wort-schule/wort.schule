# frozen_string_literal: true

FactoryBot.define do
  factory :learning_group do
    name { Faker::Team.name }
    association :owner, factory: :user
  end
end
