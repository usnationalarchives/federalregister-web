require File.dirname(__FILE__) + '/../../../../spec_helper'

module RegulationsDotGov
  describe CommentForm::Field::TextField do
    let(:client) { double(:client) }
    let(:agency_acronym) { 'ITC' }

    describe '#max_length' do
      it 'returns the max length if provided' do
        attributes = {"uiControl" => "text",
                      "maxLength" => 25}
        field = CommentForm::Field.build(client, attributes, agency_acronym)

        expect( field.max_length ).to eq(attributes['maxLength'])
      end

      it 'returns 2000 if max length is not provided' do
        attributes = {"uiControl" => "text",
                      "maxLength" => -1}
        field = CommentForm::Field.build(client, attributes, agency_acronym)

        expect( field.max_length ).to eq(2000)
      end
    end
  end
end
