FactoryGirl.define do
  factory :user do
    email "test_user@example.com"
    password "password"
    password_confirmation "password"
  end
end
