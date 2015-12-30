require 'spec_helper'

describe CitationsHelper do
  include CitationsHelper
  include Citations::CfrHelper
  include HtmlHelper

  def h(str)
    ERB::Util.html_escape(str)
  end

  describe 'add_eo_links' do
    [
      'Executive Order 12944',
      'EO 12944',
      'E. O. 12944',
      'E.O. 12944',
      'Executive Order No 12944',
      'Executive Order No. 12,944'
    ].each do |citation|
      it "supports '#{citation}'" do
        expect(add_eo_links(citation)).to eq '<a class="eo" href="' + executive_order_path(12944) + '">' + citation + '</a>'
      end
    end
  end
  describe 'add_usc_links' do
    it "supports '# USC #'" do
      expect(add_usc_links('10 USC 1')).to eq '<a class="usc external" href="' + h(usc_url('10', '1')) + '" target="_blank">10 USC 1</a>'
    end

    it "supports '# U.S.C. #'" do
      expect(add_usc_links('10 U.S.C. 1')).to eq '<a class="usc external" href="' + h(usc_url('10', '1')) + '" target="_blank">10 U.S.C. 1</a>'
    end

    it "supports '39 U.S.C. 3632, 3633, or 3642'" do
      skip
    end
    it "supports '39 U.S.C. 3632, 3633, or 3642 and 39 CFR part 3015'" do
      skip
    end
  end

  describe 'add_regulatory_plan_links' do
    it "links RINs to the appropriate regulation page" do
      expect(add_regulatory_plan_links("See RIN 1234-AB12 and RIN 1234-AB34")).to eq 'See RIN <a href="/r/1234-AB12">1234-AB12</a> and RIN <a href="/r/1234-AB34">1234-AB34</a>'
    end
  end

  describe 'add_federal_register_links' do
    it "links post 1994 FR citations to this site" do
      expect(add_federal_register_links('60 FR 1000')).to eq '<a href="/citation/60-FR-1000">60 FR 1000</a>'
    end

    it "does nothing with pre-1994 FR citations" do
      expect(add_federal_register_links('10 FR 1000')).to eq '10 FR 1000'
    end
  end

  describe 'add_public_law_links' do
    it "supports 'Public Law #-#'" do
      expect(add_public_law_links("Public Law 107-295")).to eq '<a class="publ external" href="' + h(public_law_url('107','295')) + '" target="_blank">Public Law 107-295</a>'
    end

    it "supports 'Pub. Law #-#'" do
      expect(add_public_law_links("Pub. Law 107-295")).to eq '<a class="publ external" href="' + h(public_law_url('107','295')) + '" target="_blank">Pub. Law 107-295</a>'
    end

    it "supports 'Pub. L. #-#'" do
      expect(add_public_law_links("Pub. L. 107-295")).to eq '<a class="publ external" href="' + h(public_law_url('107', '295')) + '" target="_blank">Pub. L. 107-295</a>'
    end

    it "supports 'P.L. #-#'" do
      expect(add_public_law_links("P.L. 107-295")).to eq '<a class="publ external" href="' + h(public_law_url('107', '295')) + '" target="_blank">P.L. 107-295</a>'
    end
  end

  describe 'adding links to HTML' do
    it 'should not interfere with existing links' do
      expect(add_citation_links('<a href="#">10 CFR 100</a>')).to eq '<a href="#">10 CFR 100</a>'
    end

    it 'should not interfere with existing HTML but add its own links' do
      expect(add_citation_links('<p><a href="#">10 CFR 100</a> and (<em>hi</em>) <em>alpha</em> beta 10 CFR 10 omega</em></p>')).to eq ('<p><a href="#">10 CFR 100</a> and (<em>hi</em>) <em>alpha</em> beta <a class="cfr external" href="' +  h(select_cfr_citation_path(Time.current.to_date, '10','10')) + '">10 CFR 10</a> omega</p>')
    end
  end
end
