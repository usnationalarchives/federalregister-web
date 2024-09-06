require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::EndMatter" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  before :each do
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

  # billing codes are often associated with images and appear once for
  # each image leading to them all being hoisted together to the end of the
  # document and creating a mess - https://www.federalregister.gov/d/2021-16519
  context "duplicative billing codes" do
    it "are only output once" do
      process <<-XML
        <BILCOD>BILLING CODE 4120-01-P</BILCOD>
        <BILCOD>BILLING CODE 4120-01-C</BILCOD>
        <BILCOD>BILLING CODE 4120-01-P</BILCOD>
        <BILCOD>BILLING CODE 4120-01-C</BILCOD>
        <BILCOD>BILLING CODE 4120-01-P</BILCOD>
        <BILCOD>BILLING CODE 4120-01-C</BILCOD>
      XML

      expect_equivalent <<-HTML
        <div class="end-matter">
          <p class="billing-code">BILLING CODE 4120-01-P</p>
          <p class="billing-code">BILLING CODE 4120-01-C</p>
        </div>
      HTML
    end
  end
end
