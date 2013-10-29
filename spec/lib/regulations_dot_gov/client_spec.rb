require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::Client do
  let(:api_key) { 'DEMO_KEY' }

  describe '.override_base_uri' do
    it "sets base_uri for RegulationsDotGov::Client" do
      url = 'http://example.com/api/v1'
      RegulationsDotGov::Client.override_base_uri(url)

      RegulationsDotGov::Client.base_uri.should eq(url)
    end

    after(:all) do
      RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/v2/')
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
    let(:client) { RegulationsDotGov::Client.new(api_key) }
    let(:docket_id) { 'APHIS-2013-0071' }

    it 'returns a new RegulationsDotGov::Docket' do
      docket = client.find_docket(docket_id)
      expect( docket.class ).to be( RegulationsDotGov::Docket )
    end
  end
end
