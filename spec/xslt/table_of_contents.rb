require 'nokogiri'
require 'xslt_transform'
require 'action_controller'
require 'pry'

# stub rails root so we can run tests without loading the whole environment
XsltTransform::RAILS_ROOT = File.expand_path(File.join(__FILE__, '../../../'))

describe "XSLT::TableOfContents" do
  def process(xml, type = "RULE")
    @html = XsltTransform.transform_xml(
      "<#{type}>#{xml}</#{type}>",
      "documents/table_of_contents.html.xslt"
    )
  end

  def html_document
    HTML::Document.new("<html>#{@html}</html>")
  end

  def expect_equivalent(expected_output)
    expect(
      XsltTransform.standardized_html(@html.to_xml)
    ).to eql(
      XsltTransform.standardized_html(expected_output)
    )
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
      <ul class="table_of_contents">
        <li class="level-1">
          <a href="#h-1">SUPPLEMENTARY INFORMATION:</a>
        </li>
        <li class="level-2">
          <a href="#h-2">Background</a>
        </li>
        <li class="level-2">
          <a href="#h-3">Specific Changes Made by This Rule</a>
        </li>
        <li class="level-3">
          <a href="#h-4">Creation of License Exception Support for the Cuban People (SCP)</a>
        </li>
        <li class="level-4">
          <a href="#h-5">Expansion of License Exception Consumer Communications Devices (CCD)</a>
        </li>
        <li class="level-2">
          <a href="#h-6">Export Administration Act</a>
        </li>
        <li class="level-5">
          <a href="#h-7">Expansion of License Exception Gift Parcels and Humanitarian Donations (GFT)</a>
        </li>
      </ul>
    HTML
  end

  it "creates table of contents without AGENCY, ACTION, or SUMMARY headers" do
    process <<-XML
      <AGY>
        <HD SOURCE="HED">AGENCY:</HD>
        <P>Bureau of Industry and Security, Commerce.</P>
      </AGY>
      <ACT>
        <HD SOURCE="HED">ACTION:</HD>
        <P>Final rule.</P>
      </ACT>
      <SUM>
        <HD SOURCE="HED">SUMMARY:</HD>
        <P>This rule amends the Export Administration Regulations to create License Exception Support for the Cuban People (SCP) to authorize the export and reexport of certain items to Cuba that are intended to improve the living conditions of the Cuban people; support independent economic activity and strengthen civil society in Cuba; and improve the free flow of information to, from, and among the Cuban people. It also amends existing License Exception Consumer Communications Devices (CCD) by eliminating the donation requirement, thereby authorizing sales of certain communications items to eligible end users in Cuba. Additionally, it amends License Exception Gift Parcels and Humanitarian Donations (GFT) to authorize exports of multiple gift parcels in a single shipment. Lastly, this rule establishes a general policy of approval for exports and reexports to Cuba of items for the environmental protection of U.S. and international air quality, and waters, and coastlines. These actions are among those announced by the President on December 17, 2014, aimed at supporting the ability of the Cuban people to gain greater control over their own lives and determine their country's future.</P>
      </SUM>
      <DATES>
        <HD SOURCE="HED">DATES:</HD>
        <P>This rule is effective January 16, 2015.</P>
      </DATES>
      <HD SOURCE="HED">SUPPLEMENTARY INFORMATION:</HD>
      <HD SOURCE="HD1">Background</HD>
    XML

    expect_equivalent <<-HTML
      <ul class="table_of_contents">
        <li class="level-1">
          <a href="#h-4">DATES:</a>
        </li>
        <li class="level-1">
          <a href="#h-5">SUPPLEMENTARY INFORMATION:</a>
        </li>
        <li class="level-2">
          <a href="#h-6">Background</a>
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
      <ul class="table_of_contents">
        <li class="level-1">
          <a href="#h-1">SUPPLEMENTARY INFORMATION:</a>
        </li>
        <li class="level-2">
          <a href="#h-2">
            Proposed Critical Habitat Designation for
            <em>Harrisia aboriginum</em>
          </a>
        </li>
      </ul>
    HTML
  end

  context "document types" do
    %w(RULE NOTICE).each do |doc_type|
      it "creates a table of contents for documents of type #{doc_type}" do
        process <<-XML, doc_type
          <HD SOURCE="HED">SUPPLEMENTARY INFORMATION:</HD>
          <HD SOURCE="HD1">Background</HD>
        XML

        expect_equivalent <<-HTML
          <ul class="table_of_contents">
            <li class="level-1">
              <a href="#h-1">SUPPLEMENTARY INFORMATION:</a>
            </li>
            <li class="level-2">
              <a href="#h-2">Background</a>
            </li>
          </ul>
        HTML
      end
    end
  end
end
