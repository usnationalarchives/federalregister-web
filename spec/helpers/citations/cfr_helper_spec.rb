require 'spec_helper'

describe Citations::CfrHelper do
  include Citations::CfrHelper
  def h(str)
    ERB::Util.html_escape(str)
  end

  describe 'add_cfr_links' do
    it "supports '# CFR #'" do
      expect(add_cfr_links('10 CFR 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '">10 CFR 100</a>'
    end

    it "supports '# CFR #'" do
      expect(add_cfr_links('10 CFR 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '">10 CFR 100</a>'
    end

    it "supports '# CFR #.#'" do
      expect(add_cfr_links('10 CFR 100.1')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100', '1')) + '">10 CFR 100.1</a>'
    end

    it "supports '# C.F.R. #.#'" do
      expect(add_cfr_links('10 C.F.R. 100.1')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100','1')) + '">10 C.F.R. 100.1</a>'
    end

    it "supports '# C.F.R. Part #.#'" do
      expect(add_cfr_links('10 C.F.R. Part 100.1')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100','1')) + '">10 C.F.R. Part 100.1</a>'
    end

    it "supports '# C.F.R. parts #'" do
      expect(add_cfr_links('10 C.F.R. parts 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '">10 C.F.R. parts 100</a>'
    end

    it "supports '# C.F.R. Sec. #'" do
      expect(add_cfr_links('10 C.F.R. Sec. 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '">10 C.F.R. Sec. 100</a>'
    end

    it "supports '# C.F.R. &#xA7; #'" do
      expect(add_cfr_links('10 C.F.R. &#xA7; 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10', '100')) + '">10 C.F.R. &#xA7; 100</a>'
    end

    it "supports '# C.F.R. &#xA7;&#xA7; #'" do
      expect(add_cfr_links('10 C.F.R. &#xA7;&#xA7; 100')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','100')) + '">10 C.F.R. &#xA7;&#xA7; 100</a>'
    end

    it "supports multiple citations like '# CFR #.# and # CFR #.#'" do
      expect(add_cfr_links('10 CFR 660.719 and 10 CFR 665.28')).to eq '<a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','660','719')) + '">10 CFR 660.719</a> and <a class="cfr external" href="' + h(select_cfr_citation_path(Time.current.to_date,'10','665','28')) + '">10 CFR 665.28</a>'
    end

    it("supports missing the initial space: '49 CFR230.105(c)'") { skip }
    it("supports '15 CFR parts 4 and 903'") { skip }
    it("supports '33 CFR Parts 160, 161, 164, and 165'") { skip }
    it("supports '18 CFR 385.214 or 385.211'") { skip }
    it("supports '7 CFR 2.22, 2.80, and 371.3'") { skip }
  end
end
