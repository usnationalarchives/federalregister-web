FactoryGirl.define do
  factory :folder do
    user { User.first || build(:user) }
    sequence(:name) {|n| "Test folder #{n}"}
    slug { name.downcase.gsub(' ', '-') }
  end
end
