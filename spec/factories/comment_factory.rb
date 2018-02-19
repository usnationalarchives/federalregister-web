FactoryGirl.define do
  factory :comment do
    sequence(:document_number) {|n| "2011-#{1000+n}"}
    confirm_submission { true }

    factory :comment_skipped_validations do
      to_create {|instance| instance.save(validate: false) }
    end
  end

end
