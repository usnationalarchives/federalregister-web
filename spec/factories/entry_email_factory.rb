FactoryGirl.define do
  factory :entry_email do
    remote_ip "1.1.1.1"
    sender "john@example.com"
    recipients "jane@example.com"
    document_number "2016-01234"
  end
end
