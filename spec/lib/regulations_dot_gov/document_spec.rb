require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::Document do
  let(:client) { double(:client) }

  describe "#title" do
    it "returns the document title" do
      document_title = "Notice of Request"
      document = RegulationsDotGov::Document.new(client, {'title' => document_title})
      
      expect( document.title ).to eq(document_title)
    end
  end

  describe "#docket_id" do
    it "returns the docket id" do
      docket_id = "EPA-HQ-SFUND-1999-0013"
      document = RegulationsDotGov::Document.new(client, {'docketId' => docket_id})
      
      expect( document.docket_id ).to eq(docket_id)
    end
  end

  describe "#document_id" do
    it "returns the document id" do
      document_id = "EPA-HQ-SFUND-1999-0013-0084"
      document = RegulationsDotGov::Document.new(client, {'documentId' => document_id})
      
      expect( document.document_id ).to eq(document_id)
    end
  end

  describe "#url" do
    it "returns the document url on regulations.gov" do
      document_id = "EPA-HQ-SFUND-1999-0013-0084"
      document = RegulationsDotGov::Document.new(client, {'documentId' => document_id})
      
      expect( document.url ).to eq("http://www.regulations.gov/#!documentDetail;D=#{document_id}")
    end
  end

  describe "#comment_url" do
    let(:document_id) { "EPA-HQ-SFUND-1999-0013-0084" }

    it "returns the comment url to regulations.gov when comments are open for the document" do
      comments_open = true
      document = RegulationsDotGov::Document.new(client, {'documentId' => document_id, 'canCommentOnDocument' => comments_open})
      
      expect( document.comment_url ).to eq("http://www.regulations.gov/#!submitComment;D=#{document_id}")     
    end

    it "returns nil when comments are not open for the document" do
      comments_open = false
      document = RegulationsDotGov::Document.new(client, {'documentId' => document_id, 'canCommentOnDocument' => comments_open})
      
      expect( document.comment_url ).to eq(nil)     
    end
  end

  describe "#comment_due_date" do
    it "returns the comment due date as a DateTime when present" do
      comment_due_date = "November 21 2013, at 11:59 PM Eastern Standard Time"
      document = RegulationsDotGov::Document.new(client, {'commentDueDate' => comment_due_date})
      
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
      document = RegulationsDotGov::Document.new(client, {'numCommentsReceived' => comment_count})

      expect( document.comment_count ).to eq(comment_count)
    end
  end
end
