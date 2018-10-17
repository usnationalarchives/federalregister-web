include EncryptionUtils
FactoryGirl.define do
  factory :comment do
    sequence(:document_number) {|n| "2011-#{1000+n}"}
    confirm_submission { true }
    comment_tracking_number 'XXXX-1234-XXXX'
    comment_publication_notification false
    agency_name 'Department of Agriculture'
    agency_participating true

    secret 'commentsecret'

    encrypted_comment_data {
      encrypt([{label: 'Comment', values: ['Test comment']}].to_json)
    }

    factory :comment_skipped_validations do
      to_create {|instance| instance.save(validate: false) }
    end

    trait :non_participating_agency do
      agency_participating false
    end

    trait :publicly_posted do
      comment_document_number 'AG-2018-12345'
    end
  end
end
