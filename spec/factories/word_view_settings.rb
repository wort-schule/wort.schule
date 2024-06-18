# frozen_string_literal: true

FactoryBot.define do
  factory :word_view_setting do
    name { Faker::Team.name }
    association :owner, factory: :user
  end
end
