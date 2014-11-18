require File.dirname(__FILE__) + '/../../../spec_helper'

module RegulationsDotGov
  describe CommentForm::Field do
    let(:client) { double(:client) }
    let(:agency_acronym) { 'ITC' }

    describe ".build" do
      it "builds a text field when the field is of type text" do
        attributes = {"uiControl" => "text"}

        expect( CommentForm::Field.build(client, attributes, agency_acronym).class ).to be(CommentForm::Field::TextField)
      end

      it "builds a select field when the field is of type picklist" do
        attributes = {"uiControl" => "picklist"}

        expect( CommentForm::Field.build(client, attributes, agency_acronym).class ).to be(CommentForm::Field::SelectField)
      end

      it "builds a combo field when the field is of type combo" do
        attributes = {"uiControl" => "combo"}

        expect( CommentForm::Field.build(client, attributes, agency_acronym).class ).to be(CommentForm::Field::ComboField)
      end

      it "raises an error when the field is an unrecognized type" do
        attributes = {"uiControl" => "strange"}
        message = "Invalid field type '#{attributes['uiControl']}'."

        expect{ CommentForm::Field.build(client, attributes, agency_acronym) }.to raise_exception(CommentForm::Field::InvalidInputError, message)
      end
    end

    describe "#name" do
      it "returns the field's name" do
        attributes = {'attributeName' => 'first_name',
                      'uiControl' => 'text'}

        expect( CommentForm::Field.build(client, attributes, agency_acronym).name ).to eq(attributes['attributeName'])
      end
    end

    describe "#label" do
      it "returns the field's label" do
        attributes = {'attributeLabel' => 'First Name',
                      'uiControl' => 'text'}

        expect( CommentForm::Field.build(client, attributes, agency_acronym).label ).to eq(attributes['attributeLabel'])
      end
    end

    describe "#hint" do
      it "returns the field's tooltip" do
        attributes = {'tooltip' => "Submitter's first name",
                      'uiControl' => 'text'}

        expect( CommentForm::Field.build(client, attributes, agency_acronym).hint ).to eq(attributes['tooltip'])
      end
    end

    describe "#required?" do
      it "returns true when required" do
        attributes = {'required' => true,
                      'uiControl' => 'text'}
        expect( CommentForm::Field.build(client, attributes, agency_acronym).required? ).to eq(true)
      end

      it "returns false when not required" do
        attributes = {'required' => false,
                      'uiControl' => 'text'}

        expect( CommentForm::Field.build(client, attributes, agency_acronym).required? ).to eq(false)
      end
    end

    describe "#publically_viewable?" do
      it "returns true when the field will be publically viewable" do
        attributes = {'publicViewable' => true,
                      'uiControl' => 'text'}

        expect( CommentForm::Field.build(client, attributes, agency_acronym).publically_viewable? ).to eq(true)
      end

      it "returns false when the field will not be publically viewable" do
        attributes = {'publicViewable' => false,
                      'uiControl' => 'text'}

        expect( CommentForm::Field.build(client, attributes, agency_acronym).publically_viewable? ).to eq(false)
      end
    end
  end
end

#{
            #"attribute": "SUBMITTER_FIRST_NAME",
            #"attributeLabel": "First Name",
            #"attributeName": "first_name",
            #"category": "PUBLIC SUBMISSIONS",
            #"controlLines": "1",
            #"dependsOn": "",
            #"groupId": "si_name",
            #"lookupName": "",
            #"maxLength": 25,
            #"sequence": 5100,
            #"tooltip": "Submitter's first name",
            #"uiControl": "text"
        #}
