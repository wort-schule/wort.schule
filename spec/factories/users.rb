FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { "secret123" }
    password_confirmation { "secret123" }
  end

  factory :admin, class: Admin, parent: :user do
    role { "Admin" }
  end

  factory :teacher, class: Teacher, parent: :user do
    role { "Teacher" }
  end

  factory :student, class: Student, parent: :user do
    role { "Student" }
  end
end
