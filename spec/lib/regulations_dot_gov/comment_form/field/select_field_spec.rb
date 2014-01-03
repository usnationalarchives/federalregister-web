require File.dirname(__FILE__) + '/../../../../spec_helper'

module RegulationsDotGov
  describe CommentForm::Field::SelectField do
    let(:client) { double(:client) }
    let(:agency_acronym) { 'ITC' }

    describe '#option_values' do
      it "returns an array" do
        attributes = {"uiControl" => "picklist",
                      "attributeName" => "country"}
        field = CommentForm::Field.build(client, attributes, agency_acronym)

        #expect(field.option_values.class).to be(Array)
      end

      it "calls get_options on the client with field name and empty parameters" do
        attributes = {"uiControl" => "picklist",
                      "attributeName" => "country"}
        field = CommentForm::Field.build(client, attributes, agency_acronym)

        client.should_receive(:get_option_elements).with("country", {})
        field.option_values
      end
    end
  end
end
#{
    #"attributeLabel": "Country",
    #"attributeName": "country",
    #"lookupName": "country_v",
    #"maxLength": 50,
    #"tooltip": "Submitter's country",
    #"uiControl": "picklist"
#}
