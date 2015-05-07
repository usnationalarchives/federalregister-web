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

    expect(html).to have_tag("span", with: {
      'data-page' => '1000',
      class: 'printed-page icon-fr2 icon-fr2-doc-generic cj-tooltip',
      id: "page-1000"
    })
  end

  it "creates the proper structure for displaying the icons, etc." do
    process <<-XML
      <PRTPAGE P="1000"/>
    XML

    expect(html).to have_tag("span.printed-page-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.printed-page.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "Start Printed Page 1000"} do

          with_text " "
        end
      end
    end
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

