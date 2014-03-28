require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::Document do
  before(:all) do
    $response_keys = Array.new
  end

  let(:client) { double(:client) }

  describe "#title" do
    it "returns the document title" do
      document_title = {
        "label" => "Document Title",
        "value" => "Airworthiness Directives: Beechcraft Corporation Airplanes"
      }
      document = RegulationsDotGov::Document.new(client,
                                                 track_response_keys({'title' => document_title}))

      expect( document.title ).to eq(document_title["value"])
    end
  end

  describe "#docket_id" do
    it "returns the docket id" do
      docket_id = {
        "label" => "Docket ID",
        "value" => "FAA-2013-0611"
      }
      document = RegulationsDotGov::Document.new(client,
                                                 track_response_keys({'docketId' => docket_id}))

      expect( document.docket_id ).to eq(docket_id["value"])
    end
  end

  describe "#document_id" do
    it "returns the document id" do
      document_id = {
        "label" => "Document ID",
        "value" => "FAA-2013-0611-0005"
      }
      document = RegulationsDotGov::Document.new(client,
                                                 track_response_keys({'documentId' => document_id}))

      expect( document.document_id ).to eq(document_id["value"])
    end
  end

  describe "#url" do
    it "returns the document url on regulations.gov" do
      document_id = {
        "label" => "Document ID",
        "value" => "FAA-2013-0611-0005"
      }
      document = RegulationsDotGov::Document.new(client,
                                                 track_response_keys({'documentId' => document_id}))

      expect( document.url ).to eq("http://www.regulations.gov/#!documentDetail;D=#{document_id['value']}")
    end
  end

  describe "#comment_url" do
    let(:document_id) {
      Hash.new(
        "label" => "Document ID",
        "value" => "FAA-2013-0611-0005"
      )
    }

    it "returns the comment url to regulations.gov when comments are open for the document" do
      comments_open = true
      document = RegulationsDotGov::Document.new( client,
                                                  track_response_keys(
                                                    {'documentId' => document_id,
                                                    'openForComment' => comments_open}
                                                  ))

      expect( document.comment_url ).to eq("http://www.regulations.gov/#!submitComment;D=#{document_id['value']}")
    end

    it "returns nil when comments are not open for the document" do
      comments_open = false
      document = RegulationsDotGov::Document.new( client,
                                                  track_response_keys(
                                                    {'documentId' => document_id,
                                                    'openForComment' => comments_open}
                                                  ))

      expect( document.comment_url ).to eq(nil)
    end
  end

  describe "#comment_due_date" do
    it "returns the comment due date as a DateTime when present" do
      comment_due_date = "2014-04-02T23:59:59-04:00"
      document = RegulationsDotGov::Document.new(client,
                                                 track_response_keys({'commentDueDate' => comment_due_date}))

      expect( document.comment_due_date ).to eq( DateTime.parse(comment_due_date) )
    end

    it "returns nil when the comment due date is not present" do
      comment_due_date = nil
      document = RegulationsDotGov::Document.new(client,
                                                 track_response_keys({'commentDueDate' => comment_due_date}))

      expect( document.comment_due_date ).to eq(nil)
    end
  end

  describe "#comment_count" do
    it "returns the number of comments received for a document" do
      number_of_items_recieved = {
        "label" => "Number of Comments Received",
        "value" => "20"
      }
      document = RegulationsDotGov::Document.new(client,
                                                 track_response_keys({'numItemsRecieved' => number_of_items_recieved}))

      expect( document.comment_count ).to eq(number_of_items_recieved['value'].to_i)
    end
  end

  describe "#federal_register_document_number" do
    it "returns the federal register document number for a document" do
      document_number = {
        "label" => "Federal Register Number",
        "value" => "2014-01832"
      }

      document = RegulationsDotGov::Document.new(client,
                                                 track_response_keys({'federalRegisterNumber' => document_number}))

      expect( document.federal_register_document_number ).to eq(document_number['value'])
    end
  end

  context "verify keys" do
    let(:client) { RegulationsDotGov::Client.new() }

    before (:each) do
      RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/beta/')
    end

    after(:each) do
      RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/beta/')
    end

    it "ensures all keys used in tests above actually exist in the api response", :vcr do
      document_number = '2014-01832'
      document = client.find_by_document_number(document_number)

      document_keys = document.raw_attributes.keys
      $response_keys.each do |key|
        expect( document_keys.include?(key) ).to be_true, "expected api response to contain #{key}, but did not find it in #{document_keys.inspect}"
      end
    end
  end
end

#{
#"allowLateComment":false,
#"commentDueDate":null,
#"commentStartDate":"2014-01-31T00:00:00-05:00",
#"fileFormats":[
#   "https://api.data.gov/regulations/beta/download?documentId=FAA-2013-0611-0005&contentType=pdf",
#   "https://api.data.gov/regulations/beta/download?documentId=FAA-2013-0611-0005&contentType=html"],
# "openForComment":false,
# "postedDate":"2014-01-31T00:00:00-05:00",
# "receivedDate":"2014-01-31T00:00:00-05:00",
# "status":"Posted",
# "topics":["Air Transportation","Aircraft","Aviation Safety","Incorporation by Reference","Safety"],
# "docketTitle":{
#   "label":"Docket Title",
#   "value":"2013-CE-019-AD"
# },
# "pageCount":{
#   "label":"Page Count",
#   "value":"3"
# },
# "docketType":{
#   "label":"Docket Type",
#   "value":"Rulemaking"
# },
# "documentType":{
#   "label":"Document Type",
#   "value":"Rule"
# },
# "docSubType":{
#   "label":"Document SubType",
#   "value":"Final Rule"
# },
# "federalRegisterNumber":{
#   "label":"Federal Register Number",
#   "value":"2014-01832"
# },
# "attachmentCount":{
#   "label":"Attachment Count",
#   "value":"0"
# },
# "agencyName":{
#   "label":"Agency Name",
#   "value":"Federal Aviation Administration"
# },
# "rin":{
#   "label":"RIN",
#   "value":"Not Assigned"
# },
# "title":{
#   "label":"Document Title",
#   "value":"Airworthiness Directives: Beechcraft Corporation Airplanes"
# },
# "startEndPage":{
#   "label":"Start End Page",
#   "value":"5254 - 5256"
# },
# "docketId":{
#   "label":"Docket ID",
#   "value":"FAA-2013-0611"
# },
# "documentId":{
#   "label":"Document ID",
#   "value":"FAA-2013-0611-0005"
# },
# "numItemsRecieved":{
#   "label":"Number of Comments Received",
#   "value":"0"
# },
# "cfrPart":{
#   "label":"CFR Part",
#   "value":"14 CFR Part 39"
# },
# "agencyAcronym":{
#   "label":"Agency",
#   "value":"FAA"
# }
#}
