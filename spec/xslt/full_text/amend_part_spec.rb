#encoding: utf-8
require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Subject" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "renders the AMDPAR leading number in a span" do
    process <<-XML
      <AMDPAR>
        1. The authority citation for part 3555 continues to read as follows:
      </AMDPAR>
    XML

    expect(html).to have_tag('p.amendment-part#p-amd-1') do
      with_text /The authority citation for part 3555 continues to read as follows:/

      with_tag('span.amendment-part-number') do
        with_text "1. "
      end
    end
  end

  it "renders the AMDPAR leading letter in a span" do
    process <<-XML
      <AMDPAR>
        a. Under Section 1026.32-Requirements for High-Cost Mortgages
      </AMDPAR>
    XML

    expect(html).to have_tag('p.amendment-part#p-amd-1') do
      with_text /Under Section 1026.32-Requirements for High-Cost Mortgages/

      with_tag('span.amendment-part-subnumber') do
        with_text "a. "
      end
    end
  end

  it "renders the AMDPAR as is when the text does not begin with a number or letter" do
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

  it "properly renders nested formatting tags" do
    process <<-XML
      <AMDPAR>
        1. The authority citation
        <E T="03">
          Section 1026.32-Requirements for High-Cost Mortgages,
        </E>
      </AMDPAR>

      <AMDPAR>
        a. Under
        <E T="03">Section 1026.32-Requirements for High-Cost Mortgages,</E>
      </AMDPAR>
    XML
puts html
    expect(html).to have_tag('p.amendment-part#p-amd-1') do
      with_text /1\. The authority citation/
    end

    expect(html).to have_tag('p.amendment-part#p-amd-1') do
      with_text /Section 1026.32-Requirements for High-Cost Mortgages,/
    end

    expect(html).to have_tag('p.amendment-part#p-amd-2') do
      with_text /a\. Under/
    end

    expect(html).to have_tag('p.amendment-part#p-amd-2') do
      with_text /Section 1026.32-Requirements for High-Cost Mortgages,/
    end
  end
end
