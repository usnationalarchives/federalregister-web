require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Subject" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "renders SUBJECT node as header/paragraph combo" do
    process <<-XML
      <SUBJECT>Federal Plan Requirements for Sewage Sludge Incineration Units Constructed on or Before October 14, 2010</SUBJECT>
    XML

    expect_equivalent <<-HTML
      <h1 id="h-subject" class="document-subject">SUBJECT:</h1>
      <p id="p-1" data-page="1000">Federal Plan Requirements for Sewage Sludge Incineration Units Constructed on or Before October 14, 2010</p>
    HTML
  end

  it "ignores SUBJECT nodes located with in a CONTENTS node" do
    process <<-XML
      <CONTENTS>
        <SECHD>Sec.</SECHD>
        <HD SOURCE="HD1">Applicability</HD>
        <SECTNO>62.15855</SECTNO>
        <SUBJECT>Am I subject to this subpart?</SUBJECT>
      </CONTENTS>
    XML

    expect(html).not_to have_tag("h1", with: {class: 'document-subject'})
  end

  it "ignores SUBJECT nodes located with in a SECTION node" do
    process <<-XML
      <SECTION>
        <SECTNO>&#xA7; 62.15860</SECTNO>
        <SUBJECT>What SSI units are exempt from the Federal Plan?</SUBJECT>
      </SECTION>
    XML

    expect(html).not_to have_tag("h1", with: {class: 'document-subject'})
  end
end
