require 'spec_helper'

feature "Document" do
  let(:document) do
    OpenStruct.new(
      document_number: "2014-0000",
      year: "2014",
      month: "01",
      day: "01",
      slug: "test-document",
      title: "Test Document",
      type: "Notice",
      abstract: "This is a test document"
    )
  end
  let(:document_path) do
    "/documents/#{document.year}/#{document.month}/#{document.day}/#{document.document_number}/#{document.slug}"
  end

  before(:each) do
    FederalRegister::Document.stub(:find).and_return(document)
  end

  scenario "visiting a document page" do
    visit document_path

    save_and_open_page
    expect(page).to have_selector("div.title", text: "Notice")
  end
end
