require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::PrintPage" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "creates a span with the proper class for a PRTPAGE node" do
    process <<-XML
      <PRTPAGE P="1000"/>
    XML

    expect_equivalent <<-HTML
      <span class="printed-page" id="page-1000" data-page="1000"> </span>
    HTML
  end

  it "ignores PRTPAGE nodes inside of footnotes" do
    process <<-XML
      <PRTPAGE P="1000" />
      <FTNT>
        <PRTPAGE/>
      </FTNT>
      <PRTPAGE P="1001"/>
    XML

    expect(html).to have_tag("span#page-1000")
    expect(html).to have_tag("span#page-1001")
  end
end

