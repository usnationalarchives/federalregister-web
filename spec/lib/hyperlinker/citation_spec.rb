require File.dirname(__FILE__) + '/../../spec_helper'

describe "Citations" do

  def hyperlink(text)
    FederalRegisterReferenceParser.hyperlink_with_fr_defaults(text)
  end

  it "links Executive Order citations with the expected options" do
    expect(hyperlink('Executive Order 12944')).to eq '<a href="/executive-order/12944" class="eo">Executive Order 12944</a>'
  end

  it "links United States Code citations with the expected options" do
    expect(hyperlink('10 USC 1')).to eq '<a href="https://www.govinfo.gov/link/uscode/10/1" class="usc external" target="_blank" rel="noopener noreferrer">10 USC 1</a>'
  end

  it "links Code of Federal Regulations citations with the expected options" do
    expect(hyperlink('10 CFR 100')).to eq '<a href="https://www.ecfr.gov/current/title-10/part-100" class="cfr external" target="_blank" rel="noopener noreferrer">10 CFR 100</a>'
  end  

  if Settings.regulatory_plan
    it "links RINs to the appropriate regulation page" do
      expect(hyperlink("See RIN 1234-AB12 and RIN 1234-AB34")).to eq 'See <a href="/r/1234-AB12" class="regulatory_plan">RIN 1234-AB12</a> and <a href="/r/1234-AB34" class="regulatory_plan">RIN 1234-AB34</a>'
    end
  end

  it "links Federal Register citations with relative paths" do
    expect(hyperlink('60 FR 1000')).to eq '<a href="/citation/60-FR-1000" class="fr-reference" data-reference="60 FR 1000">60 FR 1000</a>'
  end

  it "links Public Law citations with the expected options" do
    expect(hyperlink("Public Law 107-295")).to eq '<a href="https://www.govinfo.gov/link/plaw/107/public/295" class="publ external" target="_blank" rel="noopener noreferrer">Public Law 107-295</a>'
  end
end
