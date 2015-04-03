FactoryGirl.define do
  sequence :state_value do |n|
    "State #{n}"
  end

  sequence :state_label do |n|
    "State #{n}"
  end

  factory :comment_form_state_option, class: RegulationsDotGov::CommentForm::Option do
    transient do
      attrs { {"value" => generate(:state_value), "label" => generate(:state_label)} }
      client ""
    end

    initialize_with do
      new(client, attrs)
    end
  end
end
