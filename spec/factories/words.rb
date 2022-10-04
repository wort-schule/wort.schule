# frozen_string_literal: true

FactoryBot.define do
  factory :word do
    name { Faker::Verb.base }
    actable { Adjective.new }
  end
end
