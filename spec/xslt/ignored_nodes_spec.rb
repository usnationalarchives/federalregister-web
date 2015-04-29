require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::IgnoredNodes" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "nodes in the preamble with no child nodes" do
    it "ignores the AGENCY node" do
      process <<-XML
        <AGENCY TYPE="F">DEPARTMENT OF AGRICULTURE</AGENCY>
        <HD SOURCE="HED">Not Ignored</HD>
      XML

      expect_equivalent '<h1 id="h-1">Not Ignored</h1>'
    end

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

  context "nodes in the preamble that have child nodes" do
    context "and are closed properly" do
      it "ignores the AGY node" do
        process <<-XML
          <AGY>
            <HD SOURCE="HED">AGENCY:</HD>
            <P>Animal and Plant Health Inspection Service, USDA.</P>
          </AGY>
          <HD SOURCE="HED">Not Ignored</HD>
        XML

        expect_equivalent '<h1 id="h-2">Not Ignored</h1>'
      end

      it "ignores the ACT node" do
        process <<-XML
          <ACT>
            <HD SOURCE="HED">ACTION:</HD>
            <P>Final rule; technical amendment.</P>
          </ACT>
          <HD SOURCE="HED">Not Ignored</HD>
        XML

        expect_equivalent '<h1 id="h-2">Not Ignored</h1>'
      end
    end

    # this is obviously not how things *should* be
    # however when it happens this ensures the rest of the
    # document doesn't get hidden
    context "and are not closed properly" do
      it "does not ignore the contents of the AGY node" do
        process <<-XML
          <AGY>
            <HD SOURCE="HED">AGENCY:</HD>
            <P>Animal and Plant Health Inspection Service, USDA.</P>

            <HD SOURCE="HD2">Some document header:</HD>
            <P>Additional stuff...</P>
            <P>Additional stuff...</P>
          </AGY>
        XML

        expect_equivalent <<-HTML
          <h1 id="h-1">AGENCY:</h1>
          <p id="p-1" data-page="1000">Animal and Plant Health Inspection Service, USDA.</p>

          <h3 id="h-2">Some document header:</h3>
          <p id="p-2" data-page="1000">Additional stuff...</p>
          <p id="p-3" data-page="1000">Additional stuff...</p>
        HTML
      end

      it "does not ignore the contents of the ACT node" do
        process <<-XML
          <ACT>
            <HD SOURCE="HED">ACTION:</HD>
            <P>Final rule; technical amendment.</P>

            <HD SOURCE="HD2">Some document header:</HD>
            <P>Additional stuff...</P>
            <P>Additional stuff...</P>
          </ACT>
        XML

        expect_equivalent <<-HTML
          <h1 id="h-1">ACTION:</h1>
          <p id="p-1" data-page="1000">Final rule; technical amendment.</p>

          <h3 id="h-2">Some document header:</h3>
          <p id="p-2" data-page="1000">Additional stuff...</p>
          <p id="p-3" data-page="1000">Additional stuff...</p>
        HTML
      end
    end
  end
end
