require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Tables" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "GPOTABLE" do
    it "adds a unique ESI for each document" do
      process <<-XML
        <GPOTABLE><BOXHD><CHED><E T="04">ABC</E></CHED></BOXHD></GPOTABLE>

        <GPOTABLE><BOXHD><CHED>DEF</CHED></BOXHD></GPOTABLE>
      XML

      # ideally, we wouldn't include the xmlns declaration here
      #   can't seem to find a way to exclude it when generated
      #   from a nested XSLT template
      expect_equivalent <<-HTML
        <esi:include
          xmlns:esi="http://www.edge-delivery.org/esi/1.0"
          src="/documents/tables/html/2014/10/15/2014-12345/1.html"></esi:include>
        <esi:include
          xmlns:esi="http://www.edge-delivery.org/esi/1.0"
          src="/documents/tables/html/2014/10/15/2014-12345/2.html"></esi:include>
      HTML
    end
  end
end
