# frozen_string_literal: true

FactoryBot.define do
  factory :word_attribute_edit do
    change_group
    word factory: :noun
    attribute_name { "case_1_plural" }
    value { "Katzen" }
  end
end
