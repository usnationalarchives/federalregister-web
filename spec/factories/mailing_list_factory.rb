FactoryGirl.define do
  factory :mailing_list do
    parameters                  { Hash.new }
    active_subscriptions_count  1
  end

  factory :article_mailing_list,
          parent: :mailing_list,
          class: MailingList::Article do
    title 'All Articles'
  end

  factory :public_inspection_mailing_list,
          parent: :mailing_list,
          class: MailingList::PublicInspectionDocument do
    title 'All Public Inspection Documents'
  end
end
