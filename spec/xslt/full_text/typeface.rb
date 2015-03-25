require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Headers" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "formats T=04 as strong" do
    process <<-XML
      <P>
        In a final rule published in the<E T="04">Federal Register</E>on November 10
      </P>
    XML

    expect_equivalent <<-HTML
      <p id="p-1" data-page="1000">
        In a final rule published in the<strong>Federal Register</strong>on November 10
      </p>
    HTML
  end
end
