require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Paragraphs" do
  before :all do
    @template = "documents/full_text.html.xslt"
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

    it "renders FP nodes as paragraphs" do
      process <<-XML
        <FP>In a final rule published in the Federal Register</FP>
      XML

      expect_equivalent <<-HTML
        <p id="p-1" data-page="1000">In a final rule published in the Federal Register</p>
      HTML
    end

    it "multiple paragraphs get the incrementing id's so they can be targeted" do
      process <<-XML
        <P>In a final rule published in the Federal Register</P>
        <FP>Paragraph 2...</FP>
        <P>Paragraph 3...</P>
        <FP>Paragraph 4...</FP>
      XML

      expect_equivalent <<-HTML
        <p id="p-1" data-page="1000">In a final rule published in the Federal Register</p>
        <p id="p-2" data-page="1000">Paragraph 2...</p>
        <p id="p-3" data-page="1000">Paragraph 3...</p>
        <p id="p-4" data-page="1000">Paragraph 4...</p>
      HTML
    end
  end
end
