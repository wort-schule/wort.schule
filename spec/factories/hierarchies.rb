# frozen_string_literal: true

FactoryBot.define do
  factory :hierarchy do
    name { Faker::Job.field }
  end
end
