require './spec/support/xslt_test_helper'
include XsltTestHelper
include DocumentMarkupHelper

describe "XSLT::Preamble" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "documents containing expected preamble headers like ACT, ADD, etc." do
    it "moves sibling nodes into the addresses tag and properly marks up h & p tags" do
      process <<-XML
        <PREAMB>
          <ACT>
            <HD SOURCE="HED">ACTION:</HD>
            <P>Notification of availability.</P>
          </ACT>
          <P>Other action paragraph.</P>
          <SUM>
            <HD SOURCE="HED">SUMMARY:</HD>
            <P>The Food and Drug Administration is announcing</P>
          </SUM>
          <P>Other summary paragraph</P>
          <DATES>
            <HD SOURCE="HED">DATES:</HD>
            <P>Submit written comments by September 9, 2024</P>
          </DATES>
          <P>Submit electronic comments by September 9, 2024</P>
          <EFFDATE>
            <HD SOURCE="HED">DATES:</HD>
            <P>This direct final rule is effective October 22, 2024.</P>
          </EFFDATE>
          <P>Submit comments on or before September 23, 2024</P>
          <ADD>
            <HD SOURCE="HED">ADDRESSES:</HD>
            <P>You may submit comments as follows:</P>
          </ADD>
          <HD SOURCE="HD2">Electronic Submissions</HD>
          <P>Submit electronic comments in the following way:</P>
          <FURINF>
            <HD SOURCE="HED">FOR FURTHER INFORMATION CONTACT:</HD>
            <P>Center for Veterinary Medicine, Food and Drug Administration</P>
          </FURINF>
          <P>Rockville, MD 20855, <E T="03">x.x@fda.hhs.gov.</E></P>
        </PREAMB>
      XML

      expect_equivalent <<-HTML
        <div class="preamble">
          <div id="action">
            <h1 id="h-1">ACTION:</h1>
            <p id="p-1" data-page="1000">Notification of availability.</p>
            <p id="p-2" data-page="1000">Other action paragraph.</p>
          </div>
          <div id="summary">
            <h1 id="h-2">SUMMARY:</h1>
            <p id="p-3" data-page="1000">The Food and Drug Administration is announcing</p>
            <p id="p-4" data-page="1000">Other summary paragraph</p>
          </div>
          <div id="dates">
            <h1 id="h-3">DATES:</h1>
            <p id="p-5" data-page="1000">Submit written comments by September 9, 2024</p>
            <p id="p-6" data-page="1000">Submit electronic comments by September 9, 2024</p>
          </div>
          <div id="dates">
            <h1 id="h-4">DATES:</h1>
            <p id="p-7" data-page="1000">This direct final rule is effective October 22, 2024.</p>
            <p id="p-8" data-page="1000">Submit comments on or before September 23, 2024</p>
          </div>
          <div id="addresses">
            <h1 id="h-5">ADDRESSES:</h1>
            <p id="p-9" data-page="1000">You may submit comments as follows:</p>
            <h3 id="h-6">Electronic Submissions</h3>
            <p id="p-10" data-page="1000">Submit electronic comments in the following way:</p>
          </div>
          <div id="for-further-information-contact">
            <h1 id="h-7">FOR FURTHER INFORMATION CONTACT:</h1>
            <p id="p-11" data-page="1000">Center for Veterinary Medicine, Food and Drug Administration</p>
            <p id="p-12" data-page="1000">Rockville, MD 20855, <em>x.x@fda.hhs.gov.</em> </p>
          </div>
        </div>
      HTML
    end
  end

  it "keeps the order of elements in the preamble" do
    process <<-XML
      <PREAMB>
        <AGENCY TYPE="O">DEPARTMENT OF THE TREASURY</AGENCY>
        <SUBAGY>Internal Revenue Service</SUBAGY>
        <CFR>26 CFR Part 54</CFR>
        <DEPDOC>[REG–122319–22]</DEPDOC>
        <RIN>RIN 1545–BQ55</RIN>
        <ACT>
          <HD SOURCE="HED">ACTION:</HD>
        </ACT>
        <SUM>
          <HD SOURCE="HED">SUMMARY:</HD>
        </SUM>
        <DATES>
          <HD SOURCE="HED">DATES:</HD>
        </DATES>
        <EFFDATE>
          <HD SOURCE="HED">DATES:</HD>
        </EFFDATE>
        <ADD>
          <HD SOURCE="HED">ADDRESSES:</HD>
        </ADD>
        <FURINF>
          <HD SOURCE="HED">FOR FURTHER INFORMATION CONTACT:</HD>
        </FURINF>
      </PREAMB>
    XML

    expect_equivalent <<-HTML
      <div class="preamble">
        #{document_heading_wrapper do
        <<-HTML
          <h6 class="agency">Department of the Treasury</h6>
          <h6 class="sub-agency">Internal Revenue Service</h6>
          <ol>
            <li>26 CFR Part 54</li>
            <li>[REG&ndash;122319&ndash;22]</li>
            <li>RIN 1545&ndash;BQ55</li>
          </ol>
        HTML
        end}
        <div id="action">
          <h1 id="h-1">ACTION:</h1>
        </div>
        <div id="summary">
          <h1 id="h-2">SUMMARY:</h1>
        </div>
        <div id="dates">
          <h1 id="h-3">DATES:</h1>
        </div>
        <div id="dates">
          <h1 id="h-4">DATES:</h1>
        </div>
        <div id="addresses">
          <h1 id="h-5">ADDRESSES:</h1>
        </div>
        <div id="for-further-information-contact">
          <h1 id="h-6">FOR FURTHER INFORMATION CONTACT:</h1>
        </div>
      </div>
    HTML
  end

  # Notices are a grab bag of markup - we're dealing with known common deviations here
  context "notices without ACT, ADD, etc. preamble headers" do
    it "outputs other content not in the processed groupings above" do
      # SUBJECT node is not output in our HTML as it is the doc title
      # placing in spec as an anchor for this sort of content
      # see https://www.federalregister.gov/d/2024-08996
      process <<-XML
        <PREAMB>
          <SUBJECT>Combined Notice of Filings #1</SUBJECT>
          <P>Take notice that the Commission received the following exempt wholesale generator filings:</P>
          <P>
            <E T="03">Docket Numbers:</E>
            EG24-166-000.
          </P>
          <P>
            <E T="03">Applicants:</E>
            North Fork Solar Project, LLC.
          </P>
          <P>
            <E T="03">Description:</E>
            North Fork Solar Project, LLC submits Notice of Self-Certification of Exempt Wholesale Generator Status.
          </P>
          <P>
            <E T="03">Filed Date:</E>
            4/19/24.
          </P>
        </PREAMB>
      XML

      expect_equivalent <<-HTML
        <div class="preamble">
          <p id="p-1" data-page="1000">Take notice that the Commission received the following exempt wholesale generator filings:</p>
          <p id="p-2" data-page="1000"><em>Docket Numbers:</em> EG24-166-000. </p>
          <p id="p-3" data-page="1000"><em>Applicants:</em> North Fork Solar Project, LLC. </p>
          <p id="p-4" data-page="1000"><em>Description:</em> North Fork Solar Project, LLC submits Notice of Self-Certification of Exempt Wholesale Generator Status. </p>
          <p id="p-5" data-page="1000"><em>Filed Date:</em> 4/19/24. </p>
        </div>
      HTML
    end

    it "processes PREAMHD headers (sunshine act meetings notices)" do
      process <<-XML
        <PREAMB>
          <AGENCY TYPE="N">FEDERAL ELECTION COMMISSION</AGENCY>
          <SUBJECT>Sunshine Act Meetings</SUBJECT>
          <PREAMHD>
            <HD SOURCE="HED">TIME AND DATE:</HD>
            <P>Tuesday, September 17, 2024 at 10:00 a.m. and its continuation at the conclusion of the open meeting on September 19, 2024.</P>
          </PREAMHD>
          <PREAMHD>
            <HD SOURCE="HED">PLACE:</HD>
            <P> 1050 First Street NE, Washington, DC and virtual (this meeting will be a hybrid meeting).</P>
          </PREAMHD>
          <PREAMHD>
          <HD SOURCE="HED">STATUS:</HD>
            <P>This meeting will be closed to the public.</P>
          </PREAMHD>
          <PREAMHD>
            <HD SOURCE="HED">MATTERS TO BE CONSIDERED:</HD>
            <P>Compliance matters pursuant to 52 U.S.C. 30109.</P>
            <P>Matters concerning participation in civil actions or proceedings or arbitration.</P>
          </PREAMHD>
          <STARS/>
          <PREAMHD>
            <HD SOURCE="HED">CONTACT PERSON FOR MORE INFORMATION: </HD>
            <P>Judith Ingram, Press Officer Telephone: (202) 694-1220.</P>
          </PREAMHD>
        </PREAMB>
      XML

      expect_equivalent <<-HTML
        <div class="preamble">
          #{document_heading_wrapper do
          <<-HTML
            <h6 class="agency">Federal Election Commission</h6>
          HTML
          end}
          <div id="time-and-date">
            <h1 id="h-1">TIME AND DATE:</h1>
            <p id="p-1" data-page="1000">Tuesday, September 17, 2024 at 10:00 a.m. and its continuation at the conclusion of the open meeting on September 19, 2024.</p>
          </div>
          <div id="place">
            <h1 id="h-2">PLACE:</h1>
            <p id="p-2" data-page="1000"> 1050 First Street NE, Washington, DC and virtual (this meeting will be a hybrid meeting).</p>
          </div>
          <div id="status">
            <h1 id="h-3">STATUS:</h1>
            <p id="p-3" data-page="1000">This meeting will be closed to the public.</p>
          </div>
          <div id="matters-to-be-considered">
            <h1 id="h-4">MATTERS TO BE CONSIDERED:</h1>
            <p id="p-4" data-page="1000">Compliance matters pursuant to 52 U.S.C. 30109.</p>
            <p id="p-5" data-page="1000">Matters concerning participation in civil actions or proceedings or arbitration.</p>
          </div>
          <div class="stars cj-fancy-tooltip document-markup" data-tooltip-template="#stars-5-tooltip-template">
            <span class="icon-fr2 icon-fr2-star">* </span>
            <span class="icon-fr2 icon-fr2-star">* </span>
            <span class="icon-fr2 icon-fr2-star">* </span>
            <span class="icon-fr2 icon-fr2-star">* </span>
            <span class="icon-fr2 icon-fr2-star">*</span>
          </div>
          <div id="contact-person-for-more-information">
            <h1 id="h-5">CONTACT PERSON FOR MORE INFORMATION: </h1>
            <p id="p-6" data-page="1000">Judith Ingram, Press Officer Telephone: (202) 694-1220.</p>
          </div>
        </div>
      HTML
    end
  end

end
