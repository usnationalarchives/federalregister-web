require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::TextOnlyNodes" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "renders ACT node appropriately" do
    process <<-XML
      <ACT>
        <HD SOURCE="HED">ACTION:</HD>
        <P>Notice of proposed settlement; request for public comments.</P>
      </ACT>
    XML

    expect_equivalent <<-HTML
      <h1 id="h-1">ACTION:</h1>
      <p id="p-1" data-page="1000">Notice of proposed settlement; request for public comments.</p>
    HTML
  end

  it "renders FURINF node appropriately" do
    process <<-XML
      <FURINF>
        <HD SOURCE="HED">FOR FURTHER INFORMATION CONTACT:</HD>

        <P>
          A copy of the proposed settlement may be obtained...
        </P>
      </FURINF>
    XML

    expect(html).to have_tag('h1#h-1') do
      with_text "FOR FURTHER INFORMATION CONTACT:"
    end

    expect(html).to have_tag('p#p-1', with: {"data-page" => "1000"}) do
      with_text /A copy of the proposed settlement may be obtained.../
    end
  end
end

