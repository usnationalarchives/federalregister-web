require File.dirname(__FILE__) + '/../../spec_helper'

require 'hyperlinker/citation'

describe Hyperlinker::Citation do
  include RouteBuilder::Fr2Urls
  include Hyperlinker::Citation::UrlHelpers

  def hyperlink(text)
    Hyperlinker::Citation.perform(text)
  end

  def h(str)
    ERB::Util.html_escape(str)
  end

  describe "Executive Orders Citations" do
    [
      'Executive Order 12944',
      'EO 12944',
      'E. O. 12944',
      'E.O. 12944',
      'Executive Order No 12944',
      'Executive Order No. 12,944'
    ].each do |citation|
      it "supports '#{citation}'" do
        expect(
          hyperlink(citation)
        ).to eq '<a class="eo" href="' + executive_order_path(12944) + '">' + citation + '</a>'
      end
    end
  end

  describe 'United States Code Citations' do
    it "supports '# USC #'" do
      expect(hyperlink('10 USC 1')).to eq '<a class="usc external" href="' + h(usc_url('10', '1')) + '" target="_blank">10 USC 1</a>'
    end

    it "supports '# U.S.C. #'" do
      expect(hyperlink('10 U.S.C. 1')).to eq '<a class="usc external" href="' + h(usc_url('10', '1')) + '" target="_blank">10 U.S.C. 1</a>'
    end

    it "supports '39 U.S.C. 3632, 3633, or 3642'" do
      skip
    end
    it "supports '39 U.S.C. 3632, 3633, or 3642 and 39 CFR part 3015'" do
      skip
    end
  end


  describe 'Code of Federal Regulations Citations' do
    it "supports '# CFR #'" do
      expect(hyperlink('10 CFR 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '">10 CFR 100</a>'
    end

    it "supports '# CFR #'" do
      expect(hyperlink('10 CFR 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '">10 CFR 100</a>'
    end

    it "supports '# CFR #.#'" do
      expect(hyperlink('10 CFR 100.1')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100', '1')) + '">10 CFR 100.1</a>'
    end

    it "supports '# C.F.R. #.#'" do
      expect(hyperlink('10 C.F.R. 100.1')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100','1')) + '">10 C.F.R. 100.1</a>'
    end

    it "supports '# C.F.R. Part #.#'" do
      expect(hyperlink('10 C.F.R. Part 100.1')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100','1')) + '">10 C.F.R. Part 100.1</a>'
    end

    it "supports '# C.F.R. parts #'" do
      expect(hyperlink('10 C.F.R. parts 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '">10 C.F.R. parts 100</a>'
    end

    it "supports '# C.F.R. Sec. #'" do
      expect(hyperlink('10 C.F.R. Sec. 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '">10 C.F.R. Sec. 100</a>'
    end

    it "supports '# C.F.R. &#xA7; #'" do
      expect(hyperlink('10 C.F.R. &#xA7; 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '">10 C.F.R. &#xA7; 100</a>'
    end

    it "supports '# C.F.R. &#xA7;&#xA7; #'" do
      expect(hyperlink('10 C.F.R. &#xA7;&#xA7; 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '">10 C.F.R. &#xA7;&#xA7; 100</a>'
    end

    it "supports multiple citations like '# CFR #.# and # CFR #.#'" do
      expect(hyperlink('10 CFR 660.719 and 10 CFR 665.28')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','660','719')) + '">10 CFR 660.719</a> and <a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','665','28')) + '">10 CFR 665.28</a>'
    end

    it("supports missing the initial space: '49 CFR230.105(c)'") { skip }
    it("supports '15 CFR parts 4 and 903'") { skip }
    it("supports '33 CFR Parts 160, 161, 164, and 165'") { skip }
    it("supports '18 CFR 385.214 or 385.211'") { skip }
    it("supports '7 CFR 2.22, 2.80, and 371.3'") { skip }
  end

  if Settings.regulatory_plan
    describe 'RIN citations' do
      it "links RINs to the appropriate regulation page" do
        expect(hyperlink("See RIN 1234-AB12 and RIN 1234-AB34")).to eq 'See RIN <a href="/r/1234-AB12">1234-AB12</a> and RIN <a href="/r/1234-AB34">1234-AB34</a>'
      end
    end
  end

  describe 'Federal Register citations' do
    it "links post 1994 FR citations to this site" do
      expect(hyperlink('60 FR 1000')).to eq '<a href="/citation/60-FR-1000">60 FR 1000</a>'
    end

    it "does nothing with pre-1994 FR citations" do
      expect(hyperlink('10 FR 1000')).to eq '10 FR 1000'
    end
  end

  describe 'Public Law Citations' do
    it "supports 'Public Law #-#'" do
      expect(hyperlink("Public Law 107-295")).to eq '<a class="publ external" href="' + h(public_law_url('107','295')) + '" target="_blank">Public Law 107-295</a>'
    end

    it "supports 'Pub. Law #-#'" do
      expect(hyperlink("Pub. Law 107-295")).to eq '<a class="publ external" href="' + h(public_law_url('107','295')) + '" target="_blank">Pub. Law 107-295</a>'
    end

    it "supports 'Pub. L. #-#'" do
      expect(hyperlink("Pub. L. 107-295")).to eq '<a class="publ external" href="' + h(public_law_url('107', '295')) + '" target="_blank">Pub. L. 107-295</a>'
    end

    it "supports 'P.L. #-#'" do
      expect(hyperlink("P.L. 107-295")).to eq '<a class="publ external" href="' + h(public_law_url('107', '295')) + '" target="_blank">P.L. 107-295</a>'
    end
  end
end
