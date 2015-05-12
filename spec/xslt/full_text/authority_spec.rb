require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Authority" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "HED within AUTH becomes span with proper class in authority paragraph" do
    process <<-XML
      <AUTH>
        <HD SOURCE="HED">Authority:</HD>
        <P>Some CFR references here</P>
      </AUTH>
    XML

    expect(html).to have_tag("p.authority") do
      with_tag("span.auth-header") do
        with_text "Authority:"
      end
    end
  end

  it "P within AUTH becomes span with proper class in authority paragraph" do
    process <<-XML
      <AUTH>
        <HD SOURCE="HED">Authority:</HD>
        <P>Some CFR references here</P>
      </AUTH>
    XML

    expect(html).to have_tag("p.authority") do
      with_tag("span.auth-content") do
        with_text "Some CFR references here"
      end
    end
  end
end

