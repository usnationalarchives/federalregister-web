FactoryGirl.define do
  factory :comment_form_field, class: RegulationsDotGov::CommentForm::Field do
    ignore do
      client ""
      attrs {
              { "attributeName"  => "first_name",
                "attributeLabel" => "First Name",
                "tooltip"        => "Submitter's first name",
              }
      }
      agency_acronym "ITC"
    end

    initialize_with do
      new(client, attrs, agency_acronym)
    end
  end
end
