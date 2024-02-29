require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::DocumentHeadings" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  before :all do
    process <<-XML
      <AGENCY TYPE="S">OFFICE OF PERSONNEL MANAGEMENT</AGENCY>
      <CFR>5 CFR Part 890</CFR>
      <RIN>RIN 3206–AO48</RIN>
      <AGENCY TYPE="O">DEPARTMENT OF THE TREASURY</AGENCY>
      <SUBAGY>Internal Revenue Service</SUBAGY>
      <CFR>26 CFR Part 54</CFR>
      <DEPDOC>[REG–122319–22]</DEPDOC>
      <RIN>RIN 1545–BQ55</RIN>
    XML
  end

  it "creates the expected document headings structure" do
    expect_equivalent <<-HTML
      <div class="document-headings">
        <div class="fr-box fr-box-published-alt no-footer">
          <div class="fr-seal-block fr-seal-block-header with-hover">
            <div class="fr-seal-content">
              <h6>Document Headings</h6>
              <div class="fr-seal-meta">
                <div class="fr-seal-desc">
                  <p>
                    Document headings vary by document type but may contain
                    the following:
                  </p>
                  <ol class="bullets">
                    <li>
                      the agency or agencies that issued and signed a document
                    </li>
                    <li>
                      the number of the CFR title and the number of each part
                      the document amends, proposes to amend, or is directly
                      related to
                    </li>
                    <li>
                      the agency docket number / agency internal file number
                    </li>
                    <li>
                      the RIN which identifies each regulatory action listed in
                      the Unified Agenda of Federal Regulatory and Deregulatory
                      Actions
                    </li>
                  </ol>
                  <p>
                    See the
                    <a href="https://www.archives.gov/files/federal-register/write/handbook/ddh.pdf#page=9">
                      Document Drafting Handbook
                    </a>
                    for more details.
                  </p>
                </div>
              </div>
            </div>
          </div>
          <div class="content-block ">
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
          </div>
        </div>
      </div>
    HTML
  end
end
