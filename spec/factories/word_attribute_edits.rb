# frozen_string_literal: true

FactoryBot.define do
  factory :word_attribute_edit do
    word factory: :noun
    attribute_name { "case_1_plural" }
    value { "Katzen" }
    state { "waiting_for_review" }
  end
end
