# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    name { "Grundschule Musterberg" }
    zip_code { "60400" }
    city { "Frankfurt" }
    country { "DE" }
  end
end
