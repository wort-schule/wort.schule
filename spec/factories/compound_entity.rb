# frozen_string_literal: true

FactoryBot.define do
  factory :compound_entity do
    word
    pos { 1 }
    part factory: :noun
  end
end
