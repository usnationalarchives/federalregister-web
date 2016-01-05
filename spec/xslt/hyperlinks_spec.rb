# encoding: UTF-8

require './spec/support/xslt_test_helper'
include XsltTestHelper

# here be dragons
# careful how you paste/copy unicode letters
# your tools may convert them to composed or decomposed
# you may want to use .each_byte.to_a to compare these

describe "XSLT::Hyperlinks" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  # 2015-01205
  it "preserves existing hyperlinks with their classes" do
    process <<-XML
      <P>A <a href="http://www.example.com" class="external">http://www.example.com</a> link is preserved</P>
    XML

    expect_equivalent <<-HTML
      <p id="p-1" data-page="1000">A <a href="http://www.example.com" class="external">http://www.example.com</a> link is preserved</p>
    HTML
  end
end
