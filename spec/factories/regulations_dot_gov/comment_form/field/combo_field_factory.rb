FactoryGirl.define do
  factory :comment_form_combo_field, class: RegulationsDotGov::CommentForm::Field::ComboField do
    transient do
      client ""

      attribute_name "us_state"
      attribute_label "State or Province"
      tooltip "Submitter's state"
      ui_control "combo"
      max_length 50
      depends_on "country"

      attrs {
              { "attributeLabel"  => attribute_name,
                "attributeName"   => attribute_label,
                "tooltip"         => tooltip,
                "uiControl"       => ui_control,
                "maxLength"       => max_length,
                "dependsOn"       => depends_on,
              }
      }
      agency_acronym "ITC"
    end

    initialize_with do
      new(client, attrs, agency_acronym)
    end
  end
end

