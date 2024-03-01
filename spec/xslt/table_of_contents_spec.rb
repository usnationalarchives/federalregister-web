require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::TableOfContents" do
  before :all do
    @template = "matchers/table_of_contents.html.xslt"
  end

  def table_of_contents_ul_css
    "table-of-contents fr-list with-bullets"
  end

  it "creates a table of contents from the headers with appropriate levels" do
    process <<-XML
        <HD SOURCE="HED">SUPPLEMENTARY INFORMATION:</HD>
        <HD SOURCE="HD1">Background</HD>
        <HD SOURCE="HD1">Specific Changes Made by This Rule</HD>
        <HD SOURCE="HD2">Creation of License Exception Support for the Cuban People (SCP)</HD>
        <HD SOURCE="HD3">Expansion of License Exception Consumer Communications Devices (CCD)</HD>
        <HD SOURCE="HD1">Export Administration Act</HD>
        <HD SOURCE="HD4">Expansion of License Exception Gift Parcels and Humanitarian Donations (GFT)</HD>
    XML

    expect_equivalent <<-HTML
      <ul class="#{table_of_contents_ul_css}">
        <li class="level-1">
          <a href="#h-1" data-close-utility-nav="true">SUPPLEMENTARY INFORMATION:</a>
        </li>
        <li class="level-2">
          <a href="#h-2" data-close-utility-nav="true">Background</a>
        </li>
        <li class="level-2">
          <a href="#h-3" data-close-utility-nav="true">Specific Changes Made by This Rule</a>
        </li>
        <li class="level-3">
          <a href="#h-4" data-close-utility-nav="true">Creation of License Exception Support for the Cuban People (SCP)</a>
        </li>
        <li class="level-4">
          <a href="#h-5" data-close-utility-nav="true">Expansion of License Exception Consumer Communications Devices (CCD)</a>
        </li>
        <li class="level-2">
          <a href="#h-6" data-close-utility-nav="true">Export Administration Act</a>
        </li>
        <li class="level-5">
          <a href="#h-7" data-close-utility-nav="true">Expansion of License Exception Gift Parcels and Humanitarian Donations (GFT)</a>
        </li>
      </ul>
    HTML
  end

  it "creates the proper reference to the addresses header" do
    process <<-XML
      <ADD>
        <HD SOURCE="HED">ADDRESSES:</HD>
        <P>
          Federal Communications Commission, 445 12th Street SW., Washington, DC 20554.
        </P>
      </ADD>
    XML

    expect_equivalent <<-HTML
      <ul class="#{table_of_contents_ul_css}">
        <li class="level-1">
          <a href="#addresses" data-close-utility-nav="true">ADDRESSES:</a>
        </li>
      </ul>
    HTML
  end

  it "creates an 'no table of contents' notice when there aren't headers in the document" do
    process <<-XML
      <PREAMB>
        <SUBJECT>Combined Notice of Filings #1</SUBJECT>
        <P>
          Take notice that the Commission received the following electric corporate filings:
        </P>
      </PREAMB>
    XML

    expect_equivalent <<-HTML
      <div>There is no table of contents available for this document.</div>
    HTML
  end

  it "doesn't create a table of contents if the only headers are in NOTE or FP tags" do
    process <<-XML
      <FP>
        <HD SOURCE="HD4">
          Proposed Critical Habitat Designation for Harrisia aboriginum
        </HD>

        Land ownership within the proposed critical habitat consists of Federal (11 percent), State (48 percent), County (15 percent), and private and other (26 percent). Table 2 summarizes these units.
      </FP>
      <NOTE>
        <HD SOURCE="HD4">
          Index map of all critical habitat units for Consolea corallicola follows:
        </HD>
      </NOTE>
    XML

    expect_equivalent <<-HTML
      <div>There is no table of contents available for this document.</div>
    HTML
  end

  it "preserves emphasis in a header when adding it to the table of contents" do
    process <<-XML
      <HD SOURCE="HED">SUPPLEMENTARY INFORMATION:</HD>
      <HD SOURCE="HD1">
        Proposed Critical Habitat Designation for
        <E T="7462">Harrisia aboriginum</E>
      </HD>
    XML

    expect_equivalent <<-HTML
      <ul class="#{table_of_contents_ul_css}">
        <li class="level-1">
          <a href="#h-1" data-close-utility-nav="true">SUPPLEMENTARY INFORMATION:</a>
        </li>
        <li class="level-2">
          <a href="#h-2" data-close-utility-nav="true">
            Proposed Critical Habitat Designation for
            <em>Harrisia aboriginum</em>
          </a>
        </li>
      </ul>
    HTML
  end

  it "creates entries for LSTSUB and LSTSUB/CFR" do
    process <<-XML
      <HD SOURCE="HED">SUPPLEMENTARY INFORMATION:</HD>
      <LSTSUB>
        <HD SOURCE="HED">List of Subjects</HD>
        <CFR>40 CFR Part 52</CFR>
        <P>Environmental protectven'ion, Air pollution control, Incorporation by reference, Intergovernmental relations, Nitrogen dioxide, Ozone, Reporting and recordkeeping requirements, Volatile organic compounds.</P>
        <CFR>40 CFR Part 81</CFR>
        <P>Environmental protection, Air pollution control.</P>
      </LSTSUB>
    XML

    expect(html).to have_tag('li.level-1') do
      with_tag('a') do
        with_text "List of Subjects"
      end
    end

    expect(html).to have_tag('li.level-2') do
      with_tag('a', with:{ href: '#los-40-CFR-Part-52'}) do
        with_text "40 CFR Part 52"
      end
    end

    expect(html).to have_tag('li.level-2') do
      with_tag('a', with:{ href: '#los-40-CFR-Part-81'}) do
        with_text "40 CFR Part 81"
      end
    end
  end

  it "works for presidential documents"

  context "footnotes" do
    it "creates entries for footnotes when present" do
      process <<-XML
        <HD SOURCE="HED">SUPPLEMENTARY INFORMATION:</HD>
        <FTNT>
          <P>
            <SU>1</SU>
            Footnote 1
          </P>
        </FTNT>
        <FTNT>
          <P>
            <SU>2</SU>
            Footnote 2
          </P>
        </FTNT>
      XML

      expect(html).to have_tag('li.level-1') do
        with_tag 'a', count: 1, text: "Footnotes"
      end
    end

    it "does not create entries for footnotes when none are present" do
      process <<-XML
        <HD SOURCE="HED">SUPPLEMENTARY INFORMATION:</HD>
      XML

      expect(html).not_to have_tag('a', with: {href: '#footnotes'})
    end
  end
end
