require File.dirname(__FILE__) + '/../spec_helper'

describe "external url routes" do
  context "Regulations.gov" do
    let(:docket_id) { "USTR-2014-0001" }

    it "#regulations_dot_gov_docket_url returns the proper url" do
      # test RouteBuilder
      expect(
        regulations_dot_gov_docket_url(docket_id)
      ).to eq(
        "http://www.regulations.gov/#!docketDetail;rpp=100;so=DESC;sb=docId;po=0;D=#{docket_id}"
      )
    end

    it "#regulations_dot_gov_docket_comments_url returns the proper url" do
      # test RouteBuilder
      expect(
        regulations_dot_gov_docket_comments_url(docket_id)
      ).to eq(
        "http://www.regulations.gov/#!docketBrowser;dct=PS;rpp=100;so=DESC;sb=docId;po=0;D=#{docket_id}"
      )
    end

    it "#regulations_dot_gov_docket_supporting_documents_url returns the proper url" do
      # test RouteBuilder
      expect(
        regulations_dot_gov_docket_supporting_documents_url(docket_id)
      ).to eq(
        "http://www.regulations.gov/#!docketBrowser;dct=SR;rpp=100;so=DESC;sb=docId;po=0;D=#{docket_id}"
      )
    end

    it "#regulations_dot_gov_supporting_document_url returns the proper url" do
      # test RouteBuilder
      expect(
        regulations_dot_gov_supporting_document_url("WHD-2011-0003-9576")
      ).to eq(
        "http://www.regulations.gov/#!documentDetail;D=WHD-2011-0003-9576"
      )
    end
  end
end
