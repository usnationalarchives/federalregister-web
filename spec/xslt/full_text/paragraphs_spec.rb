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
    end
  end
end
