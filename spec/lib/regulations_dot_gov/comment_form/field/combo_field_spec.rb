require File.dirname(__FILE__) + '/../../../../spec_helper'

module RegulationsDotGov
  describe CommentForm::Field::ComboField do
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
