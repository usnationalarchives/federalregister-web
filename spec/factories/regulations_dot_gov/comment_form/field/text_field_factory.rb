FactoryGirl.define do
  factory :comment_form_text_field, class: RegulationsDotGov::CommentForm::Field::TextField do
    ignore do
      client ""

      attribute_name "first_name"
      attribute_label "First Name"
      tooltip "Submitter's first name"
      ui_control "text"
      max_length 25

      attrs {
              { "attributeName"   => attribute_name,
                "attributeLabel"  => attribute_label,
                "tooltip"         => tooltip,
                "uiControl"       => ui_control,
                "maxLength"       => max_length,
              }
      }
      agency_acronym "ITC"
    end

    initialize_with do
      new(client, attrs, agency_acronym)
    end
  end
end
