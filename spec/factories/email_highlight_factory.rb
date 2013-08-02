FactoryGirl.define do
  factory :email_highlight do
    sequence("name") {|n| "highlight_#{n}"}
    created  "08/01/2013"
    sequence("title") {|n| "Highlight #{n}"}
    image    "image.png"
    content  "Some content here"
    priority 1
    enabled  true
    in_rotation true
  end
end
