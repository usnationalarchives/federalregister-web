require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Stars" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "converts STARS node into the appropriate representation" do
    process <<-XML
      <STARS/>
    XML

    expect_equivalent <<-HTML
      <div class="stars cj-fancy-tooltip" data-star-count="5">
        <span class="icon-fr2 icon-fr2-star">* </span>
        <span class="icon-fr2 icon-fr2-star">* </span>
        <span class="icon-fr2 icon-fr2-star">* </span>
        <span class="icon-fr2 icon-fr2-star">* </span>
        <span class="icon-fr2 icon-fr2-star">*</span>
      </div>
    HTML
  end
end
