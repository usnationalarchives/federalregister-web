FactoryGirl.define do
  factory :subscription do
    user_id 99999
    requesting_ip '127.0.0.1'
    environment 'test'
  end

  factory :document_subscription, parent: :subscription do
    mailing_list { build(:document_mailing_list) }
  end

  factory :public_inspection_subscription, parent: :subscription do
    mailing_list { build(:public_inspection_mailing_list) }
  end
end
