# frozen_string_literal: true

FactoryBot.define do
  factory :theme do
    name { Faker::Company.unique.name }
    description { Faker::Lorem.sentence }
    template { File.read(Rails.root.join("app/views/themes/default_noun.liquid")) }
    word_type { :noun }
    user
  end
end
