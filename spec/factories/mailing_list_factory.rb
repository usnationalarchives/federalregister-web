FactoryGirl.define do
  factory :mailing_list do
    parameters                  { Hash.new }
    active_subscriptions_count  1
  end

  factory :document_mailing_list,
          parent: :mailing_list,
          class: MailingList::Document do
    title 'All Documents'
  end

  factory :public_inspection_mailing_list,
          parent: :mailing_list,
          class: MailingList::PublicInspectionDocument do
    title 'All Public Inspection Documents'
  end
end
