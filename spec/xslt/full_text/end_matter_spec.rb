require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::EndMatter" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  before :all do
    process <<-XML
      <FRDOC>[FR Doc. 2015-01323 Filed 1-23-15; 8:45 am]</FRDOC>
      <BILCOD>BILLING CODE 3410-DM-P</BILCOD>
    XML
  end

  it "create a wrapper element with the proper class" do
    expect(html).to have_tag('div.end-matter')
  end

  it "adds the FRDOC node to the wrapper element" do
    expect(html).to have_tag('div.end-matter') do
      with_tag 'p.frdoc' do
        with_text /\[FR Doc\. 2015-01323 Filed 1-23-15; 8:45 am\]/
      end
    end
  end

  it "adds the BILCOD node to the wrapper element" do
    expect(html).to have_tag('div.end-matter') do
      with_tag 'p.billing-code' do
        with_text /BILLING CODE 3410-DM-P/
      end
    end
  end
end
