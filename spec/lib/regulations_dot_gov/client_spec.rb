require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::Client do
  describe '.override_base_uri' do
    it "should set base_uri for RegulationsDotGov::Client" do
      url = 'http://example.com/api/v1'
      RegulationsDotGov::Client.override_base_uri(url)

      RegulationsDotGov::Client.base_uri.should eq(url)
    end

    after(:all) do
      RegulationsDotGov::Client.override_base_uri('http://www.regulations.gov/api/v2')
    end
  end
end
