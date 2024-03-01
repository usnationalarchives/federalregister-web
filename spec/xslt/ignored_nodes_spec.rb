require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::IgnoredNodes" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "nodes in the preamble with no child nodes" do
    # it's the same as the document title
    it "ignores the SUBJECT node" do
      process <<-XML
        <SUBJECT>Federal Plan Requirements for Sewage Sludge</SUBJECT>
        <HD SOURCE="HED">Not Ignored</HD>
      XML

      expect_equivalent '<h1 id="h-1">Not Ignored</h1>'
    end

    # these nodes are processed specially as part of the AGENCY node
    # and we don't want them processed in the normal flow
    context "(mode != document_headings)" do
      it "ignores the SUBAGY node" do
        process <<-XML
          <SUBAGY>Animal and Plant Health Inspection Service</SUBAGY>
          <HD SOURCE="HED">Not Ignored</HD>
        XML

        expect_equivalent '<h1 id="h-1">Not Ignored</h1>'
      end

      it "ignores the CFR node" do
        process <<-XML
          <CFR>9 CFR Part 78</CFR>
          <HD SOURCE="HED">Not Ignored</HD>
        XML

        expect_equivalent '<h1 id="h-1">Not Ignored</h1>'
      end

      it "ignores the DEPDOC node" do
        process <<-XML
          <DEPDOC>[Docket No. APHIS-2009-0083]</DEPDOC>
          <HD SOURCE="HED">Not Ignored</HD>
        XML

        expect_equivalent '<h1 id="h-1">Not Ignored</h1>'
      end

      it "ignores the RIN node" do
        process <<-XML
          <RIN>RIN 0579-AD22</RIN>
          <HD SOURCE="HED">Not Ignored</HD>
        XML

        expect_equivalent '<h1 id="h-1">Not Ignored</h1>'
      end
    end
  end
end
