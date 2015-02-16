require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::PrintedPage" do
  before :all do
    @template = "documents/full_text.html.xslt"
  end

  it "uses the first page when there is no current page" do
    process <<-XML
      <P>
        Paragraph on the first printed page of the document.
      </P>
    XML

    expect_equivalent <<-HTML
      <p id="p-1" data-page="1000">
        Paragraph on the first printed page of the document.
      </p>
    HTML
  end

  it "uses the current page when there is a page defined" do
    process <<-XML
      <PRTPAGE P="1001"/>
      <P>
        Paragraph on the second printed page of the document.
      </P>
      <PRTPAGE P="1002"/>
      <P>
        Paragraph on the third printed page of the document.
      </P>
    XML

    expect_equivalent <<-HTML
      <p id="p-1" data-page="1001">
        Paragraph on the second printed page of the document.
      </p>
      <p id="p-2" data-page="1002">
        Paragraph on the third printed page of the document.
      </p>
    HTML
  end

end
