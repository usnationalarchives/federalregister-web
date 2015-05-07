require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::SupplementalInfo" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "renders SUPLINF node content correctly" do
    process <<-XML
      <SUPLINF>
        <HD SOURCE="HED">SUPPLEMENTARY INFORMATION:</HD>
        <P>In this proposed administrative settlement for recovery...</P>
        <!-- there is often a SIG node here but that is tested elsewhere -->
      </SUPLINF>
    XML

    expect(html).to have_tag("h1#h-1") do
      with_text "SUPPLEMENTARY INFORMATION:"
    end

    expect(html).to have_tag("p#p-1", with: {"data-page" => "1000"}) do
      with_text "In this proposed administrative settlement for recovery..."
    end
  end
end

