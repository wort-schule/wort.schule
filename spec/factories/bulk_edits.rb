# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_edit do
    user factory: :admin
    operation { "add" }
    field { "phenomenons" }
    word_ids { [1] }
    assigned_values { [1] }
    previous_values { {} }
  end
end
