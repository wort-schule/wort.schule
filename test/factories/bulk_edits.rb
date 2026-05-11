FactoryBot.define do
  factory :bulk_edit do
    association :user, factory: :admin
    operation { "add" }
    field { "phenomenons" }
    intent_value { {"ids" => []} }
    affected_count { 0 }
  end

  factory :bulk_edit_change do
    bulk_edit
    word { association :noun }
    previous_value { {"ids" => []} }
    applied_value { {"ids" => []} }
  end
end
