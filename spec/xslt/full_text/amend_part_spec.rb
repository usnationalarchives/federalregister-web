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

    #BB TODO: Add a paragraph with a special id for amendpar - can't use normal
    #paragraph ids as these aren't <P> tags in the xml and the counts would get
    #out of sync.
    expect(html).to have_tag('div.amendment-part') do
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

    expect(html).to have_tag('div.amendment-part') do
      with_text /The authority citation for part 3555 continues to read as follows:/
    end
  end
end

