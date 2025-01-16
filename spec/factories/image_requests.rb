# frozen_string_literal: true

FactoryBot.define do
  factory :image_request do
    word factory: :noun
    user
  end
end
