# encoding: UTF-8

require './spec/support/xslt_test_helper'
include XsltTestHelper

# here be dragons
# careful how you paste/copy unicode letters
# your tools may convert them to composed or decomposed
# you may want to use .each_byte.to_a to compare these

describe "XSLT::Diacriticals" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  # 2015-01205
  it "converts AC T='8' tags to add a bar over the prior character" do
    process <<-XML
      <P>A<AC T="8"/></P>
    XML

    expect_equivalent <<-HTML
      <p id="p-1" data-page="1000">Ā</p>
    HTML
  end

  # 2014-28674
  it "converts AC T='b' to add a dot above the prior character"

  # 2014-30212
  it "converts AC T='1' to add an acute accent above the prior character"

end
