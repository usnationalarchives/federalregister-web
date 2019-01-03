require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::Client, :reg_gov do
  let(:client) { RegulationsDotGov::Client.new() }

  before(:each) do
    RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/v3/')
  end

  describe '.override_base_uri' do
    it "sets base_uri for RegulationsDotGov::Client" do
      url = 'http://example.com/api/v1'
      RegulationsDotGov::Client.override_base_uri(url)

      expect(RegulationsDotGov::Client.base_uri).to eq(url)
    end
  end

  describe '#new' do
   it "raises an error of no API key is provided" do
     allow(RegulationsDotGov::Client).to receive(:api_key).and_return(nil)

     expect{ RegulationsDotGov::Client.new }.to raise_exception(RegulationsDotGov::Client::APIKeyError, "Must provide an api.data.gov API Key")
   end

   it "does not raise an error if an API key is provided" do
     expect{ RegulationsDotGov::Client.new }.not_to raise_exception
   end
  end

  describe '#find_docket' do
    let(:docket_id) { 'CFPB_FRDOC_0001' }

    it 'returns a new RegulationsDotGov::Docket', :vcr do
      docket = client.find_docket(docket_id)
      expect( docket.class ).to be( RegulationsDotGov::Docket )
    end

    it 'performs a get request with proper arguments' do
      allow(RegulationsDotGov::Client).to receive(:get).and_return(
        double(parsed_response: {})
      )

      expect(RegulationsDotGov::Client).to receive(:get).
        with(client.docket_endpoint, query: {docketId: docket_id})

      client.find_docket(docket_id)
    end
  end

  describe '#find_documents' do
    let(:keyword) { 'ITC-2015-0074-0001' }

    it 'returns an array of RegulationsDotGov::Document', :vcr do
      documents = client.find_documents(:s => keyword)
      expect(documents).to be_kind_of(Array)
      expect(documents.first).to be_kind_of( RegulationsDotGov::Document )
    end

    it 'performs a get request with the proper arguments' do
      allow(RegulationsDotGov::Client).to receive(:get).and_return(
        double(parsed_response: {documents: []})
      )

      expect(RegulationsDotGov::Client).to receive(:get).
        with(client.document_search_endpoint, query: {s: keyword})

      client.find_documents(s: keyword)
    end
  end

  describe "#count_documents" do
    let(:keyword) { 'ITC-2013-0207-0001' }

    it "returns a count of documents matching the search", :vcr do
      count = client.count_documents(s: keyword)
      expect(count).to be_kind_of(Integer)
    end

    it 'performs a get request with the proper arguments' do

      allow(RegulationsDotGov::Client).to receive(:get).and_return(
        double(parsed_response: {totalNumRecords: 1})
      )

      expect(RegulationsDotGov::Client).to receive(:get).
        with(client.document_search_endpoint, query: {s: keyword, countsOnly: 1})

      client.count_documents(s: keyword)
    end
  end

  describe "#find_by_document_number" do
    let(:document_number) { '2015-07647' }

    it "returns a RegulationsDotGov::Document", :vcr do
      document = client.find_by_document_number(document_number)
      expect(document).to be_kind_of( RegulationsDotGov::Document )
      expect(document.federal_register_document_number).to eq(document_number)
    end

    it 'performs a get request with the proper arguments' do
      allow(RegulationsDotGov::Client).to receive(:get).and_return(
        double(parsed_response: {})
      )

      expect(RegulationsDotGov::Client).to receive(:get).
        with(client.document_endpoint, query: {federalRegisterNumber: document_number})

      client.find_by_document_number(document_number)
    end

    context "document numbers less than 5 digits long" do
      let(:document_number) { '2015-7647' }

      it 'pads the number and gets a response', :vcr do
        document = client.find_by_document_number(document_number)
        expect(document).to be_kind_of( RegulationsDotGov::Document )
      end
    end
  end

  describe "#get_comment_form" do
    let(:regulations_dot_gov_document_id) { 'NSF_FRDOC_0001-2120' }

    it 'returns a new RegulationsDotGov::CommentForm', :vcr do
      comment_form = client.get_comment_form(regulations_dot_gov_document_id)
      expect( comment_form.class ).to be(RegulationsDotGov::CommentForm)
    end

    it 'performs a get request with proper arguments' do
      allow(RegulationsDotGov::Client).to receive(:get).and_return(
        double(parsed_response: {})
      )

      expect(RegulationsDotGov::Client).to receive(:get).
        with(client.comment_endpoint, query: {D: regulations_dot_gov_document_id})

      client.get_comment_form(regulations_dot_gov_document_id)
    end
  end

  describe "#get_option_elements", :vcr do
    let(:field_name) { 'country' }
    it "returns an array of option elements for select and combo fields" do
      options = client.get_option_elements(field_name)

      expect(options.length).to be > 0
      expect(options.first).to be_kind_of(RegulationsDotGov::CommentForm::Option)
    end

    it "performs a get request with the required arguments" do
      response = double(:response).as_null_object

      expect(RegulationsDotGov::Client).to receive(:get).
        with(client.lookup_endpoint, query: {field: field_name}).
        and_return(response)

      client.get_option_elements(field_name)
    end
  end
end
