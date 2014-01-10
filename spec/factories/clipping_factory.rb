FactoryGirl.define do
  factory :clipping do
    user { User.first || build(:user) }
    sequence(:document_number) {|n| "2011-#{1000+n}"}
  end

  factory :fr_clipping_1, parent: :clipping do
    document_number "4242-4242"
  end

  factory :fr_clipping_2, parent: :clipping do
    document_number "4343-4343"
  end

  factory :fr_clipping_3, parent: :clipping do
    document_number "4444-4444"
  end
end
