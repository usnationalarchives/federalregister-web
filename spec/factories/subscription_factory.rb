FactoryGirl.define do
  factory :subscription do
    user { User.first || build(:user) }
    email { user.email }
    requesting_ip '127.0.0.1'
    environment 'test'
    confirmed_at { Time.now }
  end

  factory :document_subscription, parent: :subscription do
    mailing_list { build(:article_mailing_list) }
  end

  factory :public_inspection_subscription, parent: :subscription do
    mailing_list { build(:public_inspection_mailing_list) }
  end
end
