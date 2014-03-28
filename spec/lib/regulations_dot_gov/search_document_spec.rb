require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::SearchDocument do
  before(:all) do
    $response_keys = Array.new
  end

  let(:client) { double(:client) }

  describe "#document_id" do
    it "returns the document id" do
      document_id = "EPA-HQ-SFUND-2005-0011-0005"
      document = RegulationsDotGov::SearchDocument.new(
        client,
        track_response_keys({'documentId' => document_id})
      )

      expect( document.document_id ).to eq(document_id)
    end
  end

  describe "#title" do
    it "returns the document title" do
      document_title = "Amendment to National Oil and Hazardous Substance Contingency Plan; National Priorities List"
      document = RegulationsDotGov::SearchDocument.new(
        client,
        track_response_keys({'title' => document_title})
      )

      expect( document.title ).to eq(document_title)
    end
  end

  context "verify against api response" do
    let(:docket_id) { "EPA-HQ-SFUND-2005-0011" }
    let(:client) { RegulationsDotGov::Client.new() }
    let(:docket) { RegulationsDotGov::Docket.new(
      client,
      {'docketId' => docket_id}
    )}
    let(:documents) { docket.supporting_documents }

    before (:all) do
      RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/beta/')
    end

    after(:all) do
      RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/beta/')
    end

    context "verify keys" do
      it "ensures all keys used in tests above actually exist in the api response", :vcr do
        document_keys = documents.first.raw_attributes.keys
        $response_keys.each do |key|
          expect( document_keys.include?(key) ).to be_true,
            "expected api response to contain #{key}, but did not find it in #{document_keys.inspect}"
        end
      end
    end

    context "verify response values" do
      context "#supporting_documents", :vcr do
        it "returns the proper number of supporting documents" do
          expect(documents.count).to eq(19)
        end

        it "returns an array RegulationsDotGov::SearchDocument's" do
          expect(documents.first.class).to be(RegulationsDotGov::SearchDocument)
        end
      end
    end
  end
end

#{
#"agencyAcronym": "EPA",
#"allowLateComment": false,
#"attachmentCount": 0,
#"commentDueDate": null,
#"commentStartDate": null,
#"docketId": "EPA-HQ-SFUND-2005-0011",
#"docketTitle": "Amendment to National Oil and Hazardous Substance Contingency Plan; National Priorities List",
#"docketType": "Rulemaking",
#"documentId": "EPA-HQ-SFUND-2005-0011-0005",
#"documentStatus": "Posted",
#"documentType": "Supporting & Related Material",
#"numberOfCommentReceived": 0,
#"openForComment": false,
#"postedDate": "2007-09-24T00:00:00-04:00",
#"rin": "Not Assigned",
#"title": "Tabernacle Drum Dump - Bibliography"
#}
