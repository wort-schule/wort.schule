# frozen_string_literal: true

FactoryBot.define do
  factory :change_group do
    state { "waiting_for_review" }
  end
end
