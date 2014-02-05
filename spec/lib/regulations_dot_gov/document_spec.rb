require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::Document do
  before(:all) do
    $response_keys = Array.new
  end

  let(:client) { double(:client) }

  describe "#title" do
    it "returns the document title" do
      document_title = "Notice of Request"
      document = RegulationsDotGov::Document.new(client, track_response_keys({'title' => document_title}))

      expect( document.title ).to eq(document_title)
    end
  end

  describe "#docket_id" do
    it "returns the docket id" do
      docket_id = "EPA-HQ-SFUND-1999-0013"
      document = RegulationsDotGov::Document.new(client, track_response_keys({'docketId' => docket_id}))

      expect( document.docket_id ).to eq(docket_id)
    end
  end

  describe "#document_id" do
    it "returns the document id" do
      document_id = "EPA-HQ-SFUND-1999-0013-0084"
      document = RegulationsDotGov::Document.new(client, track_response_keys({'documentId' => document_id}))

      expect( document.document_id ).to eq(document_id)
    end
  end

  describe "#url" do
    it "returns the document url on regulations.gov" do
      document_id = "EPA-HQ-SFUND-1999-0013-0084"
      document = RegulationsDotGov::Document.new(client, track_response_keys({'documentId' => document_id}))

      expect( document.url ).to eq("http://www.regulations.gov/#!documentDetail;D=#{document_id}")
    end
  end

  describe "#comment_url" do
    let(:document_id) { "EPA-HQ-SFUND-1999-0013-0084" }

    it "returns the comment url to regulations.gov when comments are open for the document" do
      comments_open = true
      document = RegulationsDotGov::Document.new(client, track_response_keys({'documentId' => document_id, 'canComment' => comments_open}))

      expect( document.comment_url ).to eq("http://www.regulations.gov/#!submitComment;D=#{document_id}")
    end

    it "returns nil when comments are not open for the document" do
      comments_open = false
      document = RegulationsDotGov::Document.new(client, track_response_keys({'documentId' => document_id, 'canComment' => comments_open}))

      expect( document.comment_url ).to eq(nil)
    end
  end

  describe "#comment_due_date" do
    it "returns the comment due date as a DateTime when present" do
      comment_due_date = "November 21 2013, at 11:59 PM Eastern Standard Time"
      document = RegulationsDotGov::Document.new(client, track_response_keys({'commentEndDate' => comment_due_date}))

      expect( document.comment_due_date ).to eq( DateTime.parse(comment_due_date) )
    end

    it "returns nil when the comment due date is not present" do
      document = RegulationsDotGov::Document.new(client, {})

      expect( document.comment_due_date ).to eq(nil)
    end
  end

  describe "#comment_count" do
    it "returns the number of comments received for a document" do
      comment_count = 20
      document = RegulationsDotGov::Document.new(client, track_response_keys({'numberOfCommentReceived' => comment_count}))

      expect( document.comment_count ).to eq(comment_count)
    end
  end

  describe "verify keys" do
    let(:client) { RegulationsDotGov::Client.new() }

    before (:each) do
      RegulationsDotGov::Client.override_base_uri('http://api.data.gov/TEST/regulations/v2/')
    end

    after(:each) do
      RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/v2/')
    end

    it "ensures all keys used in tests above actually exist in the api response", :vcr do
      keyword = 'ITC-2013-0207-0001'
      documents = client.find_documents(:s => keyword)
      document = documents.first

      document_keys = document.raw_attributes.keys
      $response_keys.each do |key|
        expect( document_keys.include?(key) ).to be_true, "expected api response to contain #{key}, but did not find it in #{document_keys.inspect}"
      end
    end
  end
end

#{
#  "documentId"=>"ITC-2013-0207-0001",
#  "documentType"=>"NOTICES",
#  "title"=> "Antidumping and Countervailing Duty Investigations; Results, Extensions, Amendments, etc.: Steel Wire Garment Hangers from China; Five-Year Review",
#  "documentStatus"=>"Posted",
#  "agencyId"=>"ITC",
#  "docketId"=>"ITC-2013-0207",
#  "docketTitle"=> "Antidumping and Countervailing Duty Investigations; Results, Extensions, Amendments, etc.: Steel Wire Garment Hangers from China; Five-Year Review",
#  "postedDate"=>"2013-09-03T00:00:00.000+0000",
#  "commentEndDate"=>"2013-11-18T00:00:00.000+0000",
#  "commentStartDate"=>"2013-09-03T00:00:00.000+0000",
#  "fileFormats"=>
#   ["https://api.data.gov/TEST/regulations/api/contentStreamer?objectId=090000648103902b&disposition=attachment&contentType=pdf",
#    "https://api.data.gov/TEST/regulations/api/contentStreamer?objectId=090000648103902b&disposition=attachment&contentType=html"],
#  "acceptComment"=>false,
#  "canComment"=>false,
#  "fromParticipatingAgency"=>false,
#  "attachmentCount"=>0,
#  "docketType"=>"RULEMAKING",
#  "numberOfCommentReceived"=>0
#}
