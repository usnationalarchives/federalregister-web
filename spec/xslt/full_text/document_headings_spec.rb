require './spec/support/xslt_test_helper'
include XsltTestHelper
include DocumentMarkupHelper

describe "XSLT::FullText::DocumentHeadings" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "creates the expected document headings structure" do
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

  # in practice this appears to be working correctly - but the processing here
  # in this spec seems to lose the &
  xit "renders agencies with '&' in them properly" do
    process <<-XML
      <PREAMB>
        <AGENCY TYPE="S">DEPARTMENT OF HEALTH AND HUMAN SERVICES</AGENCY>
        <SUBAGY>Centers for Medicare & Medicaid Services</SUBAGY>
        <CFR>42 CFR Parts 403, 405, 410, 411, 414, 415, 423, 424, and 425</CFR>
        <DEPDOC>[CMS-1751-F]</DEPDOC>
        <RIN>RIN 0938-AU42</RIN>
      </PREAMB>
    XML

    expect_equivalent <<-HTML
      <div class="preamble">
      #{document_heading_wrapper do
      <<-HTML
        <h6 class="agency">Department of Health and Human Services</h6>
        <h6 class="sub-agency">Centers for Medicare & Medicaid Services</h6>
        <ol>
          <li>42 CFR Parts 403, 405, 410, 411, 414, 415, 423, 424, and 425</li>
          <li>[CMS-1751-F]</li>
          <li>RIN 0938-AU42</li>
        </ol>
      HTML
      end}
      </div>
    HTML
  end

  # this represents a bad doc that needs to be corrected so the output
  # is not ideal but doesn't prevent html from being created
  it "renders missing content as expected" do
    process <<-XML
      <PREAMB>
        <AGENCY TYPE="S"/>
        <SUBAGY/>
        <CFR/>
        <DEPDOC/>
        <RIN/>
      </PREAMB>
    XML

    expect_equivalent <<-HTML
      <div class="preamble">
      #{document_heading_wrapper}
      </div>
    HTML
  end

  it "ignores empty agency headers whose immediate sibling is an agency header" do
    process <<-XML
      <PREAMB>
        <AGENCY TYPE="S"/>
        <AGENCY TYPE="F">DEPARTMENT OF ENERGY</AGENCY>
        <SUBAGY>Federal Energy Regulatory Commission </SUBAGY>
        <DEPDOC>[Docket No. RP95-408-053] </DEPDOC>
      </PREAMB>
    XML

    expect_equivalent <<-HTML
      <div class="preamble">
      #{document_heading_wrapper do
      <<-HTML
        <h6 class="agency">Department of Energy</h6>
        <h6 class="sub-agency">Federal Energy Regulatory Commission </h6>
        <ol>
          <li>[Docket No. RP95-408-053] </li>
        </ol>
      HTML
      end}
      </div>
    HTML
  end

  it "properly handles blank agency tags followed by a subagency tag" do
    process <<-XML
      <PREAMB>
        <AGENCY TYPE="S"/>
        <SUBAGY>DEPARTMENT OF THE TREASURY</SUBAGY>
      </PREAMB>
    XML

    expect_equivalent <<-HTML
      <div class="preamble">
      #{document_heading_wrapper do
      <<-HTML
        <h6 class="sub-agency">DEPARTMENT OF THE TREASURY</h6>
      HTML
      end}
      </div>
    HTML
  end

  # see C2-3011, 05-8393, Z6-18150
  it "correctly handles a print page inside an agency header" do
    process <<-XML
      <PREAMB>
        <AGENCY TYPE="F">
        <PRTPAGE P="73011"/>
        ENVIRONMENTAL PROTECTION AGENCY
        </AGENCY>
        <CFR>40 CFR Parts 141 and 142</CFR>
        <DEPDOC>[FRL-7413-9]</DEPDOC>
        <RIN>RIN 2040-AD06</RIN>
      </PREAMB>
    XML

    expect_equivalent <<-HTML
      <div class="preamble">
      #{print_page_markup(73011)}
      #{document_heading_wrapper do
      <<~HTML
        <h6 class="agency">Environmental Protection Agency</h6>
        <ol>
          <li>40 CFR Parts 141 and 142</li>
          <li>[FRL-7413-9]</li>
          <li>RIN 2040-AD06</li>
        </ol>
      HTML
      end}
      </div>
    HTML
  end
end
