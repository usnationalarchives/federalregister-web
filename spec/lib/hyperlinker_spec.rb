require 'spec_helper'

describe "Hyperlinker" do
  def hyperlink(text)
    FederalRegisterReferenceParser.hyperlink_with_fr_defaults(text)
  end

  def h(str)
    ERB::Util.html_escape(str)
  end

  describe 'adding links to HTML' do
    it 'does not interfere with existing links' do
      expect(hyperlink('<a href="#">10 CFR 100</a>')).to eq '<a href="#">10 CFR 100</a>'
    end

    it 'does not interfere with existing HTML but add its own links' do
      expect(hyperlink('<p><a href="#">10 CFR 100</a> and (<em>hi</em>) <em>alpha</em> beta 10 CFR 10 omega</p>')).to eq ('<p><a href="#">10 CFR 100</a> and (<em>hi</em>) <em>alpha</em> beta <a href="https://www.ecfr.gov/current/title-10/part-10" class="cfr external" target="_blank" rel="noopener noreferrer">10 CFR 10</a> omega</p>')
    end

    it "does ignore URLs within existing hyperlinks but add ones outside" do
      expect(hyperlink('<a href="http://www.example.com"><b>www.example.com</b></a> http://www.google.com')).to eql '<a href="http://www.example.com"><b>www.example.com</b></a> <a href="http://www.google.com" class="external" target="_blank" rel="noopener noreferrer">http://www.google.com</a>'
    end

    it "hyperlinks emails" do
      expect(hyperlink('contact jane@example.com')).to eql 'contact <a href="mailto:jane@example.com" class="email">jane@example.com</a>'
    end

    it "preserves space and capitalization" do
      xml = <<-XML
        <P A="1">
          <E A="B">Foo</E>d
          is good
        </p>
      XML
      expect(hyperlink(xml)).to eql xml
    end
  end
end
