require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::Client do
  before(:all) do
    set_api_key
  end

  let(:client) { RegulationsDotGov::Client.new() }

  before(:each) do
    RegulationsDotGov::Client.override_base_uri('http://api.data.gov/TEST/regulations/v2/')
  end

  after(:each) do
    RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/v2/')
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
      RegulationsDotGov::Client.api_key = nil
      expect{ RegulationsDotGov::Client.new }.to raise_exception(RegulationsDotGov::Client::APIKeyError, "Must provide an api.data.gov API Key")
    end

    it "does not raise an error if an API key is provided" do
      RegulationsDotGov::Client.api_key = set_api_key
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
      RegulationsDotGov::Client.stub(:get).and_return(OpenStruct.new(:parsed_response => {}))

      RegulationsDotGov::Client.should_receive(:get).with(client.docket_endpoint, :query=>{:D => docket_id})

      client.find_docket(docket_id)
    end
  end

  describe "#get_comment_form" do
    let(:document_id) { 'ITC-2013-0207-0001' }

    it 'returns a new RegulationsDotGov::CommentForm', :vcr do
      comment_form = client.get_comment_form(document_id)
      expect( comment_form.class ).to be(RegulationsDotGov::CommentForm)
    end

    it 'performs a get request with proper arguments' do
      RegulationsDotGov::Client.stub(:get).and_return(OpenStruct.new(:parsed_response => {}))

      RegulationsDotGov::Client.should_receive(:get).with(client.comment_endpoint, :query=>{:D => document_id})

      client.get_comment_form(document_id)
    end
  end

  describe "#get_option_elements" do
    let(:field_name) { 'country' }
    it "returns an array of option elements for select and combo fields" do
      options = client.get_option_elements(field_name)

      expect(options.length).to be > 0
      expect(options.first).to be_kind_of(RegulationsDotGov::CommentForm::Option)
    end

    it "performs a get request with the required arguments" do
      response = double(:response).as_null_object

      RegulationsDotGov::Client.should_receive(:get).with(client.lookup_endpoint, :query=>{:field => field_name}).and_return(response)
      client.get_option_elements(field_name)
    end
  end

  def set_api_key
    if SECRETS['data_dot_gov'] && SECRETS['data_dot_gov']['api_key']
      RegulationsDotGov::Client.api_key = SECRETS['data_dot_gov']['api_key']
    else
       RegulationsDotGov::Client.api_key'DEMO_KEY'
    end
  end
end
