require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Subject" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "renders the AMDPAR as two spans when the text begins with a number" do
    process <<-XML
      <AMDPAR>
        1. The authority citation for part 3555 continues to read as follows:
      </AMDPAR>
    XML

    expect(html).to have_tag('p.amendment-part#p-amd-1') do
      with_tag('span.amendment-part-number') do
        with_text "1."
      end
      with_tag('span.amendment-part-text') do
        with_text " The authority citation for part 3555 continues to read as follows:"
      end
    end
  end

  it "renders the AMDPAR as is when the text does not begin with a number" do
    process <<-XML
      <AMDPAR>
        The authority citation for part 3555 continues to read as follows:
      </AMDPAR>
    XML

    expect(html).to have_tag('p.amendment-part#p-amd-1') do
      with_text /The authority citation for part 3555 continues to read as follows:/
    end
  end

  it "adds the proper paragraph id's on successive AMDPAR elements" do
    process <<-XML
      <AMDPAR>
        Amendment part 1...
      </AMDPAR>

      <P>Some text.</P>

      <AMDPAR>
        Amendment part 2...
      </AMDPAR>
    XML

    expect(html).to have_tag('p.amendment-part#p-amd-1') do
      with_text /Amendment part 1/
    end

    expect(html).to have_tag('p.amendment-part#p-amd-2') do
      with_text /Amendment part 2/
    end
  end
end

