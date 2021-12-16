# encoding: utf-8
require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Section" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "CONTENTS node" do
    it "renders a div with a definition list inside" do
      process <<-XML
        <CONTENTS>
          <SECHD>Sec.</SECHD>
          <HD SOURCE="HD1">Applicability</HD>
          <SECTNO>62.15855</SECTNO>
          <SUBJECT>Am I subject to this subpart?</SUBJECT>
        </CONTENTS>
      XML

      expect(html).to have_tag("div",
        with: {class: 'regulatory-table-of-contents'}) do
          with_tag("dl", with: {class: "fr-list fr-list-inline"})
        end
    end

    it "renders each SECTNO as a dt wiht a link within dl" do
      process <<-XML
        <CONTENTS>
          <SECTNO>62.15855</SECTNO>
          <SUBJECT>Am I subject to this subpart?</SUBJECT>
        </CONTENTS>
      XML

      expect(html).to have_tag("dl") do
          with_tag("dt", with: {class: 'sectno sectno-citation', id: "sectno-citation-62.15855"}) do
            with_tag("a", with: {href: '#sectno-reference-62.15855'}) do
              with_text "62.15855"
            end
          end
        end
    end

    it "renders each SUBJECT following a SECTNO as a dd after the proper dt" do
      process <<-XML
        <CONTENTS>
          <SECTNO>62.15855</SECTNO>
          <SUBJECT>Am I subject to this subpart?</SUBJECT>
        </CONTENTS>
      XML

      expect_equivalent <<-HTML
        <div class="regulatory-table-of-contents">
          <dl class="fr-list fr-list-inline">
            <dt class="sectno sectno-citation" id="sectno-citation-62.15855">
              <a href="#sectno-reference-62.15855">62.15855</a>
            </dt>
            <dd class="sectno-subject">Am I subject to this subpart?</dd>
          </dl>
        </div>
      HTML
    end

    it "renders headers as lh (list headers) with the proper header size class" do
      process <<-XML
        <CONTENTS>
          <SECHD>Sec.</SECHD>
          <HD SOURCE="HD1">Applicability</HD>
          <SECTNO>62.15855</SECTNO>
          <SUBJECT>Am I subject to this subpart?</SUBJECT>
        </CONTENTS>
      XML

      expect(html).to have_tag("dl") do
        with_tag("lh", with: {class: 'sectno-header sectno-header-2'})
      end
    end
  end

  context "SECTION node" do
    it "renders a div with a class of section" do
      process <<-XML
        <SECTION>
          <SECTNO>&#xA7; 62.15865</SECTNO>
          <SUBJECT>How do I determine if my SSI is covered by an approved and effective State or Tribal plan?</SUBJECT>

          <P>This part (40 CFR part 62) contains a list of all states and tribal areas...</P>
        </SECTION>
      XML

      expect(html).to have_tag("div",
        with: {class: 'section'})
    end

    it "renders SECTNO nodes as a div with proper class, links, and id" do
      process <<-XML
        <CONTENTS>
          <SECHD>Sec.</SECHD>
          <HD SOURCE="HD1">Applicability</HD>
          <SECTNO>62.15855</SECTNO>
          <SUBJECT>Am I subject to this subpart?</SUBJECT>
          <SECTNO>62.15856</SECTNO>
          <SUBJECT>Am I subject to this other subpart?</SUBJECT>
        </CONTENTS>

        <SECTION>
          <SECTNO>&#xA7; 62.15855</SECTNO>
          <SUBJECT>Am I subject to this subpart?</SUBJECT>

          <P>This part (40 CFR part 62) contains a list of all states and tribal areas...</P>
        </SECTION>
      XML

      expect(html).to have_tag("div",
        with: {class: 'section'}) do
          with_tag("div", with: {class: "sectno sectno-reference", id: "sectno-reference-62.15855"}) do
            with_tag("a", with: {href: '#sectno-citation-62.15855'}) do
              with_text "§ 62.15855"
            end
          end
        end
    end

    it "renders the sectno-reference div without an additional space when a 'thinspace' character (#x2009) is included in the <SECTNO> tag between the § and the section number.  The example below is taken from document 2016-15980's XML." do

      process <<-XML
        <SECTION>
          <SECTNO>§ 361.51 </SECTNO>
        </SECTION>
      XML

      expect(html).to have_tag("div",
        with: {class: 'section'}) do
          with_tag("div", with: {class: "sectno sectno-reference", id: "sectno-reference-361.51"})
        end
    end

    it "strips trailing spaces from <SECTNO> tags when generating <dt> tags.  The example below is taken from document 2016-15980's XML." do
      process <<-XML
      <CONTENTS>
        <SUBPART>
        <HD SOURCE="HED">Subpart A—General</HD>
        <SECHD>Sec.</SECHD>
        <SECTNO>363.1 </SECTNO>
        <SUBJECT>
        </SUBJECT>
      </CONTENTS>
      XML

      expect(html).to have_tag("dt",
        with: {class: 'sectno-citation'}) do
          with_tag("a", with: {href: "#sectno-reference-363.1"})
        end
    end

    it "renders SUBJECT nodes as a div with proper class" do
      process <<-XML
        <CONTENTS>
          <SECHD>Sec.</SECHD>
          <HD SOURCE="HD1">Applicability</HD>
          <SECTNO>62.15855</SECTNO>
          <SUBJECT>Am I subject to this subpart?</SUBJECT>
          <SECTNO>62.15856</SECTNO>
          <SUBJECT>Am I subject to this other subpart?</SUBJECT>
        </CONTENTS>

        <SECTION>
          <SECTNO>&#xA7; 62.15855</SECTNO>
          <SUBJECT>Am I subject to this subpart?</SUBJECT>

          <P>This part (40 CFR part 62) contains a list of all states and tribal areas...</P>
        </SECTION>
      XML

      expect(html).to have_tag("div",
        with: {class: 'section'}) do
          with_tag("div", with: {class: "section-subject"}) do
            with_text "Am I subject to this subpart?"
          end
        end
    end

    it "renders P nodes into the section div" do
      process <<-XML
        <CONTENTS>
          <SECHD>Sec.</SECHD>
          <HD SOURCE="HD1">Applicability</HD>
          <SECTNO>62.15855</SECTNO>
          <SUBJECT>Am I subject to this subpart?</SUBJECT>
        </CONTENTS>

        <SECTION>
          <SECTNO>&#xA7; 62.15855</SECTNO>
          <SUBJECT>Am I subject to this subpart?</SUBJECT>

          <P>This part (40 CFR part 62) contains a list of all states and tribal areas...</P>
        </SECTION>
      XML

      expect(html).to have_tag("div",
        with: {class: 'section'}) do
          with_tag("p") do
            with_text "This part (40 CFR part 62) contains a list of all states and tribal areas..."
          end
        end
    end
  end
end
