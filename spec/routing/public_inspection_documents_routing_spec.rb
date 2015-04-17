require File.dirname(__FILE__) + '/../spec_helper'

describe "public inspection document routes" do
  let(:pi_document) {
    OpenStruct.new(
      publication_date: Date.parse("2014-01-01"),
      year: "2014",
      month: "01",
      day: "01",
    )
  }

  it "public-inspection routes to PublicInspectionDocumentsController#current" do
    expect(get: "public-inspection").to route_to(
      controller: "public_inspection_documents",
      action: "public_inspection",
    )
  end

  it "public-inspection/current routes to PublicInspectionDocumentsController#current" do
    expect(get: "public-inspection/current").to route_to(
      controller: "public_inspection_documents",
      action: "current",
    )

    expect(get: current_public_inspection_documents_path).to route_to(
      controller: "public_inspection_documents",
      action: "current",
    )
  end


  it "public-inspection/:year/:month/:day routes to PublicInspectionDocumentsController#show" do
    expect(get: "public-inspection/#{pi_document.year}/#{pi_document.month}/#{pi_document.day}").to route_to(
      controller: "public_inspection_document_issues",
      action: "show",
      year: pi_document.year,
      month: pi_document.month,
      day: pi_document.day,
    )

  end
end
