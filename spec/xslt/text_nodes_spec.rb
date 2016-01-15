require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::TextNodes" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "properly removing whitespace for subscripts and superscript" do
    context "T=51 tags" do
      it "covert to superscripts" do
        process <<-XML
          <P>
            food and drinking water. Using DEEM-FCID
            <E T="51">TM</E>
            , acute dietary exposure
          </P>
        XML

        expect_equivalent <<-HTML
          <p id="p-1" data-page="1000">
            food and drinking water. Using DEEM-FCID<sup>TM</sup>,
            acute dietary exposure
          </p>
        HTML
      end
    end

    context "T=52" do
      it "converts to subscripts when they occur in a comma seperated row" do
        process <<-XML
          <P>
            (thereby emitting additional PM, CO
            <E T="52">2</E>
            , SO
            <E T="52">2</E>
            , NO
            <E T="52">X</E>
            , and Hg). There are two
          </P>
        XML

        expect_equivalent <<-HTML
          <p id="p-1" data-page="1000">
            (thereby emitting additional PM, CO<sub>2</sub>, SO<sub>2</sub>,
            NO<sub>X</sub>, and Hg). There are two
          </p>
        HTML
      end

      it "coverts to subscripts when the last item does not have puntuation after it (comma, period, etc)" do
        process <<-XML
          <P>
            particulate matter (PM
            <E T="52">2.5</E>
            ) on July 18, 1997 and on October 17, 2006. The CAA requires that each state, after a new or revised NAAQS is promulgated, review their SIPs to ensure that they meet infrastructure requirements. The State of North Dakota submitted certifications of their infrastructure SIP on August 12, 2010 and May 22, 2012 for the 2006 PM
            <E T="52">2.5</E>
            NAAQS. In addition, the State of North Dakota submitted a certification of their infrastructure SIP on May 25, 2012 for the 1997 PM
            <E T="52">2.5</E>
            NAAQS. EPA is also
          </P>
        XML

        expect_equivalent <<-HTML
          <p id="p-1" data-page="1000">
            particulate matter (PM<sub>2.5</sub>) on July 18, 1997 and on
            October 17, 2006. The CAA requires that each state, after a new
            or revised NAAQS is promulgated, review their SIPs to ensure that
            they meet infrastructure requirements. The State of North Dakota
            submitted certifications of their infrastructure SIP on August
            12, 2010 and May 22, 2012 for the 2006 PM<sub>2.5</sub> NAAQS.
            In addition, the State of North Dakota submitted a certification
            of their infrastructure SIP on May 25, 2012 for the 1997
            PM<sub>2.5</sub> NAAQS. EPA is also
          </p>
        HTML
      end
    end
  end

  context "nodes that start with a bullet '&#x2022;'" do
    it "removes bullets from the P and FP nodes" do
      process <<-XML
        <P>&#x2022; Geospatial Privacy</P>
        <FP SOURCE="FP-1">&#x2022; 3D Elevation Program</FP>
      XML

      expect_equivalent <<-HTML
        <ul class="bullets">
          <li id="p-1" data-page="1000">Geospatial Privacy</li>
          <li id="p-2" data-page="1000">3D Elevation Program</li>
        </ul>
      HTML
    end

    # this example is a bit contrived but the use case is valid
    it "does not remove bullets from nodes that aren't P or FP" do
      process <<-XML
        <HD SOURCE="HED">&#x2022; GUARANTEED RURAL HOUSING PROGRAM</HD>
      XML

      expect_equivalent <<-HTML
        <h1 id="h-1">&bull; GUARANTEED RURAL HOUSING PROGRAM</li>
      HTML
    end

    context "and have sub/superscripts" do
      # this is a bit of a combination of the known major issues with
      # whitespace and sub/superscripts - now in the context of bullets
      it "renders list elements without bullets and proper positioning of sub/superscripts" do
        process <<-XML
          <P>&#x2022; Geospatial Privacy <E T="51">1</E></P>
          <P>&#x2022; Emitting additional PM, CO
            <E T="52">2</E>
            , SO
            <E T="52">2</E>
            , NO
            <E T="52">X</E>
            , and Hg.
          </P>
          <P>&#x2022; Leadership Dialogue</P>
        XML

        expect_equivalent <<-HTML
          <ul class="bullets">
            <li id="p-1" data-page="1000">Geospatial Privacy<sup>1</sup> </li>
            <li id="p-2" data-page="1000">Emitting additional PM, CO<sub>2</sub>, SO<sub>2</sub>, NO<sub>X</sub>, and Hg. </li>
            <li id="p-3" data-page="1000">Leadership Dialogue</li>
          </ul>
        HTML
      end
    end
  end

  # we've seen this when a footnote in a table gets messed up in the XML
  context "when an SU is found alone (not followed by FTREF, etc)" do
    it "renders them as a superscript" do
      process <<-XML
        Biomass-based diesel
        <SU>12</SU>
      XML

      expect_equivalent <<-HTML
        Biomass-based diesel<sup>12</sup>
      HTML
    end
  end
end
