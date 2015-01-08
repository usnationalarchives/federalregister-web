require File.dirname(__FILE__) + '/../spec_helper'

describe "fr2 url routes" do
  context "CFR citations" do
    let(:cfr_citation) do
      OpenStruct.new(
        title: 14,
        part: 39,
        section: nil,
        publication_date: Date.parse("2014-01-01")
      )
    end

    it "#select_cfr_citation_path generates the proper path" do
      # test RouteBuilder generating urls to fr2 app
      expect(select_cfr_citation_path(cfr_citation.publication_date,
                                      cfr_citation.title,
                                      cfr_citation.part,
                                      cfr_citation.section)).to eq("/select-citation/2014/01/01/14-CFR-39")

      expect(select_cfr_citation_path(cfr_citation.publication_date,
                                  cfr_citation.title,
                                  cfr_citation.part,
                                  12)).to eq("/select-citation/2014/01/01/14-CFR-39.12")
    end
  end

  it "#executive_order_path returns the proper path" do
    # test RouteBuilder
    expect( executive_order_path(13631) ).to eq("/executive-order/13631")
  end

  it "#citation_path returns the proper path" do
    # test RouteBuilder
    expect( citation_path(32, 10234) ).to eq("/citation/32/10234")
  end
end
