require File.dirname(__FILE__) + '/../../../spec_helper'

module RegulationsDotGov
  describe CommentForm::Option do
    let(:client) { double(:client) }
    let(:agency_acronym) { 'ITC' }
    let(:attributes) { {'default' => true, 'label' => 'Alabama', 'value' => 'AL'} }
    let(:comment_form_option) { RegulationsDotGov::CommentForm::Option.new(client, attributes) }

    describe "#value" do
      it "returns the value" do
        expect( comment_form_option.value ).to eq( attributes['value'] )
      end
    end

    describe "#label" do
      it "returns the label" do
        expect( comment_form_option.label ).to eq( attributes['label'] )
      end
    end

    describe "#default?" do
      it "returns true if the option is the default" do
        expect( comment_form_option.default? ).to eq( attributes['default'] )
      end
    end
  end
end

#{
#"default":true,
#"label":"Alabama",
#"value":"AL"
#}
