require 'spec_helper'

describe "FederalRegisterReferenceParser" do
  def hyperlink(text)
    FederalRegisterReferenceParser.hyperlink_with_fr_defaults(text)
  end

  describe 'adding links to HTML' do
    it 'uses relative links for FR Doc' do
      expect(hyperlink("[FR Doc. 2022-02281 Filed 2-3-22; 8:45 am]")).to eq '[<a href="/d/2022-02281">FR Doc. 2022-02281</a> Filed 2-3-22; 8:45 am]'
    end
  end
end
