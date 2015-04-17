require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Typeface" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "<E> node attributes" do
    it "formats T=02 as strong with minor-caps class" do
      process <<-XML
        <P>
          The street address for the Docket Operations office is in the
          <E T="02">ADDRESSES</E>
          section.
        </P>
      XML

      expect_equivalent <<-HTML
        <p id="p-1" data-page="1000">
          The street address for the Docket Operations office is in the
          <strong class="minor-caps">ADDRESSES</strong> section.
        </p>
      HTML
    end

    it "formats T=03 as emphasis" do
      process <<-XML
        <P>
          For service information identified in this AD, contact Airbus SAS email
          <E T="03">airworthiness.A330@airbus.com;</E>
          Internet
          <E T="03">http://www.airbus.com.</E>
          You may view this referenced service...
        </P>
      XML

      expect_equivalent <<-HTML
        <p id="p-1" data-page="1000">
          For service information identified in this AD, contact Airbus SAS
          email <em>airworthiness.A330@airbus.com;</em> Internet
          <em>http://www.airbus.com.</em> You may view this referenced service...
        </p>
      HTML
    end

    it "formats T=04 as strong" do
      process <<-XML
        <P>
          In a final rule published in the<E T="04">Federal Register</E>on November 10
        </P>
      XML

      expect_equivalent <<-HTML
        <p id="p-1" data-page="1000">
          In a final rule published in the <strong>Federal Register</strong> on November 10
        </p>
      HTML
    end

    it "formats T=34 as a span with a small-caps class" do
      process <<-XML
        <P>
          applicability determination before use of the minor NSR tools.
          <E T="34">Alaska Admin. Code</E>
          tit. 18, 50.502, approved 72 FR 45378 (August 14, 2007); 7
        </P>
      XML

      expect_equivalent <<-HTML
        <p id="p-1" data-page="1000">
          applicability determination before use of the minor NSR tools.
          <span class="small-caps">Alaska Admin. Code</span> tit. 18, 50.502,
          approved 72 FR 45378 (August 14, 2007); 7
        </p>
      HTML
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

      context "T=53" do
        it "convert to italic superscript tags" do
          process <<-XML
            <P>
              is the number of units produced for sale in the United States of each
              <E T="03">i</E>
              <E T="53">th</E>
              unique footprint within each model
            </P>
          XML

          expect_equivalent <<-HTML
            <p id="p-1" data-page="1000">
              is the number of units produced for sale in the United States of
              each <em>i</em><sup><em>th</em></sup> unique footprint within each model
            </p>
          HTML
        end
      end

      context "both T=52 and T=53" do
        it "convert properly to both subscript and superscripts when used together" do
          process <<-XML
            <P>
              <E T="03">PRODUCTION</E>
              <E T="52">i</E>
              is the number of units produced for sale in the United States of each
              <E T="03">i</E>
              <E T="53">th</E>
              unique footprint within each model type produced for sale in the United States, and
            </P>
          XML

          expect_equivalent <<-HTML
            <p id="p-1" data-page="1000">
              <em>PRODUCTION</em><sub>i</sub> is the number of units produced
              for sale in the United States of each <em>i</em><sup><em>th</em></sup>
              unique footprint within each model type produced for sale in the
              United States, and
            </p>
          HTML
        end
      end

      context "T=54" do
        it "converts to an italic subscript tag" do
          process <<-XML
            <P>
              produced for sale in the United States, and
              <E T="03">TARGET</E>
              <E T="54">i</E>
              is the corresponding fuel economy target
            </P>
          XML

          expect_equivalent <<-HTML
            <p id="p-1" data-page="1000">
              produced for sale in the United States, and
              <em>TARGET</em><sub><em>i</em></sub> is the corresponding
              fuel economy target
            </p>
          HTML
        end
      end
    end
  end
end
