require File.dirname(__FILE__) + '/../spec_helper'

describe "document routes" do
  let(:document) {
    OpenStruct.new(
      document_number: "2014-0000",
      year: "2014",
      month: "01",
      day: "01",
      slug: "test-document",
      publication_date: Date.parse("2014-01-01")
    )
  }

  it "/a/:document_number routes DocumentsController#tiny_url" do
    expect(get: "/a/#{document.document_number}").to route_to(
      controller: "documents",
      action: "tiny_url",
      document_number: document.document_number
    )
  end

  it "/d/:document_number routes DocumentsController#tiny_url" do
    expect(get: "/d/#{document.document_number}").to route_to(
      controller: "documents",
      action: "tiny_url",
      document_number: document.document_number
    )

    expect(get: short_document_path(document.document_number)).to route_to(
      controller: "documents",
      action: "tiny_url",
      document_number: document.document_number
    )
  end

  it "documents/:year/:month/:day/:document_number/:slug routes to DocumentsController#show" do
    expect(get: "documents/#{document.year}/#{document.month}/#{document.day}/#{document.document_number}/#{document.slug}").to route_to(
      controller: "documents",
      action: "show",
      year: document.year,
      month: document.month,
      day: document.day,
      document_number: document.document_number,
      slug: document.slug
    )

    # test RouteBuilder
    expect(get: document_path(document)).to route_to(
      controller: "documents",
      action: "show",
      year: document.year,
      month: document.month,
      day: document.day,
      document_number: document.document_number,
      slug: document.slug
    )
  end

  it "documents/:year/:month/:day routes to DocumentsController#index" do
    expect(get: "documents/#{document.year}/#{document.month}/#{document.day}").to route_to(
      controller: "documents",
      action: "index",
      year: document.year,
      month: document.month,
      day: document.day
    )

    #test RouteBuilder
    expect(get: documents_path(document.publication_date)).to route_to(
      controller: "documents",
      action: "index",
      year: document.year,
      month: document.month,
      day: document.day
    )

  end
end
