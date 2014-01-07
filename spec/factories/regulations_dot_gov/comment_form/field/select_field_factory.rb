FactoryGirl.define do
  factory :comment_form_select_field, class: RegulationsDotGov::CommentForm::Field::SelectField do
    ignore do
      client ""

      attribute_name "country"
      attribute_label "Country"
      tooltip "Submitter's country"
      ui_control "picklist"
      max_length 50

      attrs {
              { "attributeLabel"  => attribute_name,
                "attributeName"   => attribute_label,
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

