require './spec/support/xslt_test_helper'
include XsltTestHelper
include DocumentMarkupHelper

describe "XSLT::FullText::DocumentHeadings" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  before :all do
    process <<-XML
      <PREAMB>
        <AGENCY TYPE="S">OFFICE OF PERSONNEL MANAGEMENT</AGENCY>
        <CFR>5 CFR Part 890</CFR>
        <RIN>RIN 3206–AO48</RIN>
        <AGENCY TYPE="O">DEPARTMENT OF THE TREASURY</AGENCY>
        <SUBAGY>Internal Revenue Service</SUBAGY>
        <CFR>26 CFR Part 54</CFR>
        <DEPDOC>[REG–122319–22]</DEPDOC>
        <RIN>RIN 1545–BQ55</RIN>
      </PREAMB>
    XML
  end

  it "creates the expected document headings structure" do
    expect_equivalent <<-HTML
      <div class="preamble">
      #{document_heading_wrapper do
      <<-HTML
        <h6 class="agency">Office of Personnel Management</h6>
        <ol>
          <li>5 CFR Part 890</li>
          <li>RIN 3206&ndash;AO48</li>
        </ol>
        <h6 class="agency">Department of the Treasury</h6>
        <h6 class="sub-agency">Internal Revenue Service</h6>
        <ol>
          <li>26 CFR Part 54</li>
          <li>[REG&ndash;122319&ndash;22]</li>
          <li>RIN 1545&ndash;BQ55</li>
        </ol>
      HTML
      end}
      </div>
    HTML
  end
end
