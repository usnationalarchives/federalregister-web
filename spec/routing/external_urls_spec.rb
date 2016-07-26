require File.dirname(__FILE__) + '/../spec_helper'

describe "external url routes" do
  context "Regulations.gov" do
    let(:docket_id) { "USTR-2014-0001" }
    let(:document_id) { "WHD-2011-0003-9576" }

    it "#regulations_dot_gov_docket_url returns the proper url" do
      expect(
        regulations_dot_gov_docket_url(docket_id)
      ).to eq(
        "https://www.regulations.gov/docket?D=#{docket_id}"
      )
    end

    it "#regulations_dot_gov_docket_comments_url returns the proper url" do
      expect(
        regulations_dot_gov_docket_comments_url(docket_id)
      ).to eq(
        "https://www.regulations.gov/docketBrowser?rpp=50&so=DESC&sb=postedDate&po=0&dct=PS&D=#{docket_id}"
      )
    end

    it "#regulations_dot_gov_docket_supporting_documents_url returns the proper url" do
      expect(
        regulations_dot_gov_docket_supporting_documents_url(docket_id)
      ).to eq(
        "https://www.regulations.gov/docketBrowser?rpp=50&po=0&dct=SR&D=#{docket_id}"
      )
    end

    it "#regulations_dot_gov_supporting_document_url returns the proper url" do
      expect(
        regulations_dot_gov_supporting_document_url(document_id)
      ).to eq(
        "https://www.regulations.gov/document?D=#{document_id}"
      )
    end
  end
end
