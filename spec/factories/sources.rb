# frozen_string_literal: true

FactoryBot.define do
  factory :source do
    name { Faker::Book.title }
  end
end
