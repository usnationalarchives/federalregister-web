FactoryGirl.define do
  factory :clipping do
    user_id 1
    sequence(:document_number) {|n| "2011-#{1000+n}"}
  end
end
