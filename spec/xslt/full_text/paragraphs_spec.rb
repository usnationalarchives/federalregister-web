# encoding: utf-8
require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Paragraphs" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "basic paragraph creation" do
    it "renders P nodes as paragraphs" do
      process <<-XML
        <P>In a final rule published in the Federal Register</P>
      XML

      expect_equivalent <<-HTML
        <p id="p-1" data-page="1000">In a final rule published in the Federal Register</p>
      HTML
    end

    it "multiple paragraphs get the incrementing id's so they can be targeted" do
      process <<-XML
        <P>In a final rule published in the Federal Register</P>
        <P>Paragraph 2...</P>
        <P>Paragraph 3...</P>
        <P>Paragraph 4...</P>
      XML

      expect_equivalent <<-HTML
        <p id="p-1" data-page="1000">In a final rule published in the Federal Register</p>
        <p id="p-2" data-page="1000">Paragraph 2...</p>
        <p id="p-3" data-page="1000">Paragraph 3...</p>
        <p id="p-4" data-page="1000">Paragraph 4...</p>
      HTML
    end
  end

  context "flush paragraphs <FP>" do
    # see later in this context block for special cases
    it "renders FP nodes as paragraphs" do
      process <<-XML
        <FP>In a final rule published in the Federal Register</FP>
      XML

      expect_equivalent <<-HTML
        <p id="p-1" data-page="1000">In a final rule published in the Federal Register</p>
      HTML
    end

    it 'renders <FP SOURCE="FP-2"> tags with a class of "flush-paragraph flush-paragraph-2"' do
      process <<-XML
        <FP SOURCE="FP-2">I. Background</FP>
      XML

      expect(html).to have_tag("p",
        with: {class: 'flush-paragraph flush-paragraph-2'}) do
          with_text "I. Background"
        end
    end

    it 'renders <FP SOURCE="FP2"> tags with a class of "flush-paragraph flush-paragraph-2 flush-left"' do
      process <<-XML
        <FP SOURCE="FP2">(a) Some document text</FP>
      XML

      expect(html).to have_tag("p",
        with: {class: 'flush-paragraph flush-paragraph-2 flush-left'}) do
          with_text "(a) Some document text"
        end
    end

    it 'renders <FP SOURCE="FP1-2"> tags with a class of "flush-paragraph flush-paragraph-1-2"' do
      process <<-XML
        <FP SOURCE="FP1-2">A. Historical Overview of the IRF PPS</FP>
      XML

      expect(html).to have_tag("p",
        with: {class: 'flush-paragraph flush-paragraph-1-2'}) do
          with_text "A. Historical Overview of the IRF PPS"
        end
    end

    it 'renders <FP SOURCE="FP-1"> tags with a class of "flush-paragraph flush-paragraph-1"' do
      process <<-XML
        <FP SOURCE="FP-1">The Social Security Act</FP>
      XML

      expect(html).to have_tag("p",
        with: {class: 'flush-paragraph flush-paragraph-1'}) do
          with_text "The Social Security Act"
        end
    end

    it 'renders <FP SOURCE="FP1"> tags with a class of "flush-paragraph flush-paragraph-1 flush-left"' do
      process <<-XML
        <FP SOURCE="FP1">(i) Some document text</FP>
      XML

      expect(html).to have_tag("p",
        with: {class: 'flush-paragraph flush-paragraph-1 flush-left'}) do
          with_text "(i) Some document text"
        end
    end

    context "FP-DASH source attribute" do
      it 'renders <FP SOURCE="FP-DASH"> tags with a class of "flush-paragraph flush-paragraph-dash flush-paragraph-no-wrap"' do
        process <<-XML
          <FP SOURCE="FP-DASH">/s/</FP>
        XML

        expect(html).to have_tag("p",
          with: {class: 'flush-paragraph flush-paragraph-dash flush-paragraph-no-wrap'}) do
            with_text "/s/"
          end
      end

      it 'does not add an addition class of flush-paragraph-no-wrap to FP-DASH attributed tags of > 50 chars' do
        process <<-XML
          <FP SOURCE="FP-DASH">
          Provide up to two email addresses to which the Securities and Exchange Commission's staff may send any comment letters relating to the offering statement. After qualification of the offering statement, such email addresses are not required to remain active:
          </FP>
        XML

        expect(html).to have_tag("p",
          with: {class: 'flush-paragraph flush-paragraph-dash'}) do
            with_text /Provide up to two email addresses to which the Securities and Exchange Commission's/
        end
      end

      it 'properly renders multiple FP-DASH attributed elements in a row' do
        process <<-XML
          <FP SOURCE="FP-DASH">Name:</FP>
          <FP SOURCE="FP-DASH">Address:</FP>
          <FP SOURCE="FP-DASH">Telephone: (__)</FP>
        XML

        expect(html).to have_tag("p",
          with: {class: 'flush-paragraph flush-paragraph-dash flush-paragraph-no-wrap'}) do
            with_text "Name:"
          end

        expect(html).to have_tag("p",
          with: {class: 'flush-paragraph flush-paragraph-dash flush-paragraph-no-wrap'}) do
            with_text "Address:"
          end
      end

      it 'renders <FP> tags immediately following FP-DASH attributed tags with a class of "flush-paragraph"' do
        process <<-XML
          <FP SOURCE="FP-DASH">/s/</FP>
          <FP>Joseph F. Wayland,</FP>
        XML

        expect(html).to have_tag("p",
          with: {class: 'flush-paragraph'}) do
            with_text "Joseph F. Wayland,"
          end
      end

      it 'renders <FP> tags immediately preceeding FP-DASH attributed tags with a class of "flush-paragraph"' do
        process <<-XML
          <FP>Address of Principal Executive Offices:</FP>
          <FP SOURCE="FP-DASH"/>
        XML

        expect(html).to have_tag("p",
          with: {class: 'flush-paragraph'}) do
            with_text "Address of Principal Executive Offices:"
          end
      end


      context "nodes that start with a bullet '&#x2022;'" do
        it "renders P nodes as list elements and removes bullets" do
          process <<-XML
            <P>&#x2022; Geospatial Privacy</P>
            <P>&#x2022; 3D Elevation Program</P>
            <P>&#x2022; Leadership Dialogue</P>
          XML

          expect_equivalent <<-HTML
            <ul class="bullets">
              <li id="p-1" data-page="1000">Geospatial Privacy</li>
              <li id="p-2" data-page="1000">3D Elevation Program</li>
              <li id="p-3" data-page="1000">Leadership Dialogue</li>
            </ul>
          HTML
        end

        it "renders FP nodes as list elements and removes bullets" do
          process <<-XML
            <FP SOURCE="FP-1">&#x2022; Geospatial Privacy</FP>
            <FP SOURCE="FP-2">&#x2022; 3D Elevation Program</FP>
            <FP SOURCE="FP1-2">&#x2022; Leadership Dialogue</FP>
          XML

          expect_equivalent <<-HTML
            <ul class="bullets">
              <li id="p-1" data-page="1000">Geospatial Privacy</li>
              <li id="p-2" data-page="1000">3D Elevation Program</li>
              <li id="p-3" data-page="1000">Leadership Dialogue</li>
            </ul>
          HTML
        end

        it "handles PRTPAGE tags properly" do
          process <<-XML
            <P>Potential areas for funded AI research could include:</P>
            <P>&#x2022; Enhancing the safety of pedestrians,</P>
            <P>&#x2022; Real-time AI-based decision support tools,</P>
            <P>
            &#x2022; Offline analysis of traffic data,
            <PRTPAGE P="36851"/>
            </P>
            <P>&#x2022; Enhancing mapping and spatial AI</P>
          XML

          expect_equivalent <<-HTML
            <p id="p-1" data-page="1000">Potential areas for funded AI research could include:</p>
            <ul class="bullets">
              <li id="p-2" data-page="1000">Enhancing the safety of pedestrians,</li>
              <li id="p-3" data-page="1000">Real-time AI-based decision support tools,</li>
              <li id="p-4" data-page="1000">Offline analysis of traffic data,<span class="printed-page-inline unprinted-element document-markup" data-page="36851"> (<svg class="svg-icon svg-icon-doc-generic"><use xlink:href="/assets/fr-icons.svg#doc-generic"></use></svg> print page 36851) </span><span class="printed-page-details unprinted-element document-markup" id="page-36851" data-page="36851"><svg class="svg-icon svg-icon-doc-generic"><use xlink:href="/assets/fr-icons.svg#doc-generic"></use></svg></span> </li>
              <li id="p-5" data-page="36851">Enhancing mapping and spatial AI</li>
            </ul>
          HTML
        end
      end
    end
  end
end
