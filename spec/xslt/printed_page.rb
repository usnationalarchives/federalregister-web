require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::PrintPage" do
  def process(xml, type = "RULE")
    @html = XsltTransform.transform_xml(
      "<#{type}>#{xml}</#{type}>",
      "documents/full_text.html.xslt",
      'first_page' => "6963"
    )
  end

  it "uses the first page when there is no current page" do
    process <<-XML
      <P>
        Paragraph on the first printed page of the document.
      </P>
    XML

    expect_equivalent <<-HTML
      <p id="p-1" data-page="6963">
        Paragraph on the first printed page of the document.
      </p>
    HTML
  end

  it "uses the current page when there is a page defined" do
    process <<-XML
      <PRTPAGE P="6964"/>
      <P>
        Paragraph on the second printed page of the document.
      </P>
      <PRTPAGE P="6965"/>
      <P>
        Paragraph on the third printed page of the document.
      </P>
    XML

    expect_equivalent <<-HTML
      <p id="p-1" data-page="6964">
        Paragraph on the second printed page of the document.
      </p>
      <p id="p-2" data-page="6965">
        Paragraph on the third printed page of the document.
      </p>
    HTML
  end

end
