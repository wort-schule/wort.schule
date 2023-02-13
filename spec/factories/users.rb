FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { "secret123" }
    password_confirmation { "secret123" }
    confirmed_at { 2.days.ago }
  end

  factory :admin, class: Admin, parent: :user do
    role { "Admin" }
  end

  factory :lecturer, class: Lecturer, parent: :user do
    role { "Lecturer" }
  end

  factory :guest, class: Guest, parent: :user do
    role { "Guest" }
  end
end
