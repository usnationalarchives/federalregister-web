require File.dirname(__FILE__) + '/../../../../spec_helper'

module RegulationsDotGov
  describe CommentForm::Field::ComboField, :reg_gov do
    let(:client) { double(:client) }
    let(:agency_acronym) { 'ITC' }

    describe '#dependent_on' do
      it 'returns the attribute_name of the field that it depends on' do
        attributes = {"uiControl" => "combo",
                      "dependsOn" => "country"}
        field = CommentForm::Field.build(client, attributes, agency_acronym)

        expect( field.dependent_on ).to eq(attributes['dependsOn'])
      end
    end

    describe '#lookup_name' do
      it 'returns the name of lookup to be used to get the options for the input' do
        attributes = {"uiControl" => "combo",
                      "lookupName" => "us_state_v"}
        field = CommentForm::Field.build(client, attributes, agency_acronym)

        expect( field.lookup_name ).to eq(attributes['lookupName'])
      end
    end

    describe "#options_for_parent_value" do
      it "calls client.get_option_values with the proper parameters" do
        attributes = {"uiControl" => "combo",
                      "attributeName" => "us_state",
                      "dependsOn" => "country"}
        field = CommentForm::Field.build(client, attributes, agency_acronym)

        client.should_receive(:get_option_elements).with("us_state", {"dependentOnValue" => "United States"})
        field.options_for_parent_value('United States')
      end
    end

    describe "#dependencies" do
      it "returns an array of value, label pairs" do
        attributes = {"uiControl" => "combo",
                      "attributeName" => "us_state",
                      "dependsOn" => "country"}
        field = CommentForm::Field.build(client, attributes, agency_acronym)


        us_state_options = [FactoryGirl.build(:comment_form_state_option), FactoryGirl.build(:comment_form_state_option)]

        client.should_receive(:get_option_elements).with("us_state", {"dependentOnValue" => "United States"}).and_return( us_state_options )
        client.should_receive(:get_option_elements).with("us_state", {"dependentOnValue" => "Canada"}).and_return([])

        expect( field.dependencies ).to eq({"United States" => us_state_options.map{|o| [o.value, o.label]}, "Canada" => []})
      end
    end

    describe "#dependent_values" do
      describe "returns an array of values that should trigger a change in the options displayed" do
        it "returns ['United States', 'Canada'] for us_state" do
          attributes = {"uiControl" => "combo",
                        "attributeName" => "us_state",
                        "dependsOn" => "country"}
          field = CommentForm::Field.build(client, attributes, agency_acronym)

          expect( field.dependent_values ).to eq(['United States', 'Canada'])
        end

        it "returns ['Federal'] for gov_agency" do
          attributes = {"uiControl" => "combo",
                        "attributeName" => "gov_agency",
                        "dependsOn" => "gov_agency_type"}
          field = CommentForm::Field.build(client, attributes, agency_acronym)

          expect( field.dependent_values ).to eq(['Federal'])
        end
      end

      it "raises a unrecognized dependency error when the dependent_on field has not been configured" do
        attributes = {"uiControl" => "combo",
                      "attributeName" => "new_field",
                      "dependsOn" => "unknown_field"}
        field = CommentForm::Field.build(client, attributes, agency_acronym)

        expect{ field.dependent_values }.to raise_exception(RegulationsDotGov::CommentForm::Field::ComboField::UnrecogonizedDependencyError, "Combo field #{field.name} has unrecognized dependency for #{field.dependent_on}; needs to be configured.")
      end
    end
  end
end
#{
    #"attribute": "US_STATE",
    #"attributeLabel": "State or Province",
    #"attributeName": "us_state",
    #"category": "PUBLIC SUBMISSIONS",
    #"controlLines": "1",
    #"dependsOn": "country",
    #"groupId": "si_address",
    #"lookupName": "us_state_v",
    #"maxLength": 50,
    #"sequence": 5240,
    #"tooltip": "Submitter's state",
    #"uiControl": "combo"
#}
