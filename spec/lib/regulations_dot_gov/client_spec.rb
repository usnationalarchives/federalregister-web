require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::Client do
  let(:client) { RegulationsDotGov::Client.new( api_key ) }

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

      RegulationsDotGov::Client.base_uri.should eq(url)
    end
  end

  describe '#new' do
    it "raises an error of no API key is provided" do
      expect{ RegulationsDotGov::Client.new() }.to raise_exception(RegulationsDotGov::Client::APIKeyError, "Must provide an api.data.gov API Key")
    end

    it "does not raise an error if an API key is provided" do
      expect{ RegulationsDotGov::Client.new("1234567890") }.not_to raise_exception
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

  def api_key
    if SECRETS['data_dot_gov'] && SECRETS['data_dot_gov']['api_key']
      SECRETS['data_dot_gov']['api_key']
    else
      'DEMO_KEY'
    end
  end
end
