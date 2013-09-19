FactoryGirl.define do
  factory :email_notification do
    sequence("name") {|n| "notification_#{n}"}
    created  "08/01/2013"
    sequence("subject") {|n| "Notification #{n}"}
    html_content  "<p>Some content here<p>"
    text_content  "Some content here"
    enabled  true
  end
end
