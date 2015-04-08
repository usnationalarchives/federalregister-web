require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Signature" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  before :all do
    process <<-XML
    <SIG>
      <DATED>Done at Washington, DC on: January 21, 2015.</DATED>
      <NAME>Alfred V. Almanza,</NAME>
      <TITLE>Acting Administrator.</TITLE>
    </SIG>
  XML
  end

  it "creates a wrapper with the proper class" do
    expect(html).to have_tag('div.signature')
  end

  it "adds the signature date to the wrapper" do
    expect(html).to have_tag('div.signature') do
      with_tag "p.signature-date" do
        with_text /Done at Washington, DC on: January 21, 2015./
      end
    end
  end

  it "adds the signature name to the wrapper" do
        expect(html).to have_tag('div.signature') do
      with_tag "p.signature-name" do
        with_text /Alfred V. Almanza,/
      end
    end
  end

  it "adds the signature title to the wrapper" do
        expect(html).to have_tag('div.signature') do
      with_tag "p.signature-title" do
        with_text /Acting Administrator./
      end
    end
  end
end
