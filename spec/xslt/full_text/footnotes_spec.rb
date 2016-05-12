require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Footnotes" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "rendering the footnotes" do
    before :all do
      process <<-XML
        <FTNT>
          <P>
            <SU>1</SU>
            NCC, 2011. Broiler Industry Marketing Survey Report
          </P>
        </FTNT>
      XML
    end

    it "creates a header and appropriate footnotes div" do
      expect(html).to have_tag('h1#footnotes') do
        with_text /Footnotes/
      end

      expect(html).to have_tag('div.footnotes')
    end

    it "renders FTNT nodes as a div with the appropriate class and id" do
      expect(html).to have_tag('div.footnotes') do
        with_tag "div#footnote-1-p1000.footnote"
      end
    end

    it "renders FTNT nodes as a div with the proper content" do
      expect(html).to have_tag("div#footnote-1-p1000.footnote") do
        with_text /1.\s+NCC, 2011. Broiler Industry Marketing Survey Report/
      end
    end

    it "adds a link back to the original footnote reference in the document" do
      expect(html).to have_tag("a.back", with: {href: '#citation-1-p1000'}) do
        with_text /Back to Citation/
      end
    end
  end

  it "moves the footnotes to the bottom of the document" do
    process <<-XML
      <P>
        <SU>1</SU>
        <FTREF/>
      </P>
      <FTNT>
        <P>
          <SU>1</SU>
          Footnote 1 text
        </P>
      </FTNT>
      <PRTPAGE P="1001" />
      <P>
        <SU>2</SU>
        <FTREF/>
      </P>
      <FTNT>
        <P>
          <SU>2</SU>
          Footnote 2 text
        </P>
      </FTNT>
    XML

    expect_equivalent <<-HTML
      <p id="p-1" data-page="1000">
        <sup>[<a class="footnote-reference" href="#footnote-1-p1000" id="citation-1-p1000">1</a>] </sup>
      </p>
      <span class="printed-page-wrapper unprinted-element-wrapper">
        <span class="unprinted-element-border"></span>
        <span class="printed-page unprinted-element icon-fr2 icon-fr2-doc-generic cj-fancy-tooltip document-markup" id="page-1001" data-page="1001" data-text="Start Printed Page 1001" data-tooltip-template="#print-page-tooltip-template" data-tooltip-data="{&quot;page&quot;: 1001}"> </span>
      </span>
      <p id="p-3" data-page="1001">
        <sup>[<a class="footnote-reference" href="#footnote-2-p1001" id="citation-2-p1001">2</a>] </sup>
      </p>
      <h1 id="footnotes">Footnotes</h1>
      <div class="footnotes">
        <div class="footnote" id="footnote-1-p1000">
          <p id="p-2" data-page="1000">1. Footnote 1 text </p>
          <a class="back" href="#citation-1-p1000"> Back to Citation </a>
        </div>
        <div class="footnote" id="footnote-2-p1001">
          <p id="p-4" data-page="1001">2. Footnote 2 text </p>
          <a class="back" href="#citation-2-p1001"> Back to Citation </a>
        </div>
      </div>
    HTML
  end


  context "rendering the footnote references in the body of the document" do
    context "when footnotes are marked up as <SU> tags" do
      before :each do
        process <<-XML
          <P>
            <SU>2</SU>
            <FTREF/>
          </P>
        XML
      end

      it "creates a superscript" do
        expect(html).to have_tag("sup", count: 1)
      end

      it "creates an internal link to the footnote in the text" do
        expect(html).to have_tag("sup") do
          with_tag "a.footnote-reference", with: {href: '#footnote-2-p1000', id: "citation-2-p1000"} do
            with_text /2/
          end
        end
      end
    end

    context "when footnotes are marked up as <E T='51'> tags" do
      it "properly converts multiple footnotes in a superscript tag with multiple links" do
        process <<-XML
          <P>
            MitraClip System meets the substantial clinical improvement criterion based on clinical studies
            <E T="51">4 5 6 7</E>
            <FTREF/>
            that have consistently...
          </P>
        XML

        expect_equivalent <<-HTML
          <p id="p-1" data-page="1000">
            MitraClip System meets the substantial clinical improvement criterion
            based on clinical studies<sup>[<a class="footnote-reference" href="#footnote-4-p1000" id="citation-4-p1000">4</a>,
            <a class="footnote-reference" href="#footnote-5-p1000" id="citation-5-p1000">5</a>,
            <a class="footnote-reference" href="#footnote-6-p1000" id="citation-6-p1000">6</a>,
            <a class="footnote-reference" href="#footnote-7-p1000" id="citation-7-p1000">7</a>] </sup>
            that have consistently...
          </p>
        HTML
      end

      it "properly converts a single footnote into a superscript tag" do
        process <<-XML
          <HD SOURCE="HD1">
            II. Fees for FY 2015
            <E T="51">1</E>
            <FTREF/>
          </HD>
        XML

        expect_equivalent <<-HTML
          <h2 id="h-1">
            II. Fees for FY 2015<sup>[<a class="footnote-reference" href="#footnote-1-p1000" id="citation-1-p1000">1</a>] </sup>
          </h2>
        HTML
      end

      # addresses bug that was accumulating footnotes as it moved down the document
      it "does not stack footnotes" do
        process <<-XML
          <P>
            MitraClip System meets the substantial clinical improvement criterion
            <E T="51">2 3</E>
            <FTREF/>
            based on clinical studies
            <E T="51">4 5 6 7</E>
            <FTREF/>
            that have consistently...
          </P>
        XML

        expect_equivalent <<-HTML
          <p id="p-1" data-page="1000">
            MitraClip System meets the substantial clinical improvement
            criterion<sup>[<a class="footnote-reference" href="#footnote-2-p1000" id="citation-2-p1000">2</a>,
            <a class="footnote-reference" href="#footnote-3-p1000" id="citation-3-p1000">3</a>] </sup>
            based on clinical studies<sup>[<a class="footnote-reference" href="#footnote-4-p1000" id="citation-4-p1000">4</a>,
            <a class="footnote-reference" href="#footnote-5-p1000" id="citation-5-p1000">5</a>,
            <a class="footnote-reference" href="#footnote-6-p1000" id="citation-6-p1000">6</a>,
            <a class="footnote-reference" href="#footnote-7-p1000" id="citation-7-p1000">7</a>] </sup>
            that have consistently...
          </p>
        HTML
      end
    end

    # TODO BB: this turns out to be fairly difficult to implement
    # leaving the test but marking as no_ci for now
    context "whitespace before a footnote", :no_ci do
      it "trims the trailing whitespace when a footnote follows a formatted" do
        process <<-XML
          <P>According to<E T="03">Morse,</E>
            <SU>15</SU>

            <FTREF/>78 percent of falls
          </P>
        XML

        expect_equivalent <<-HTML
          <p id="p-1" data-page="1000">According to <em>Morse,</em><sup>[<a class="footnote-reference" href="#footnote-15-p1000" id="citation-15-p1000">15</a>] </sup>
            78 percent of falls
          </p>
        HTML
      end
    end
  end
end
