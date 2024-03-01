require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Tables" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "GPOTABLE" do
    it "adds a full html table" do
      process <<-XML
        <GPOTABLE COLS="4" OPTS="L2,nj,tp0,i1" CDEF="s100,xs48,r40,xs44">
        <TTITLE> </TTITLE>
        <BOXHD>
        <CHED H="1">Review title</CHED>
        <CHED H="1">RIN</CHED>
        <CHED H="1">Docket ID #</CHED>
        <CHED H="1">Status</CHED>
        </BOXHD>
        <ROW>
        <ENT I="01">Section 610 Review of the Tier 3 Motor Vehicle Emission and Fuel Standards</ENT>
        <ENT>2060–AV90</ENT>
        <ENT>EPA–HQ–OAR–2011–0135</ENT>
        <ENT>Ongoing.</ENT>
        </ROW>
        </GPOTABLE>
      XML

      expect_equivalent <<-HTML
        <html xmlns="http://www.w3.org/1999/xhtml">
          <body>
            <div class="table-wrapper">
              <table class="" data-point-width="232">
                <thead>
                  <tr>
                    <th class="center border-top-single border-bottom-single border-right-single">Review title</th>
                    <th class="center border-top-single border-bottom-single border-right-single">RIN</th>
                    <th class="center border-top-single border-bottom-single border-right-single">Docket ID #</th>
                    <th class="center border-top-single border-bottom-single">Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td class="left border-bottom-single border-right-single">Section 610 Review of the Tier 3 Motor Vehicle Emission and Fuel Standards</td>
                    <td class="left border-bottom-single border-right-single">2060AV90</td>
                    <td class="left border-bottom-single border-right-single">EPAHQOAR20110135</td>
                    <td class="left border-bottom-single">Ongoing.</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </body>
        </html>
      HTML
    end
  end
end
