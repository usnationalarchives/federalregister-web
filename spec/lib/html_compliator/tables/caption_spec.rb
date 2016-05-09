require File.dirname(__FILE__) + '/../../../spec_helper'

describe HtmlCompilator::Tables do
  def parse(xml)
    HtmlCompilator::Tables::Table.new(
      Nokogiri::XML(xml).root
    )
  end

  context "Table caption" do
    it "handles multiple title lines (TTITLE)" do
      table = parse <<-XML
        <GPOTABLE>
          <TTITLE>Title 1</TTITLE>
          <TTITLE>Title 2</TTITLE>
        </GPOTABLE>
      XML

      expect(table.captions.map(&:body)).to eql(["Title 1","Title 2"])
    end

    it "handles non-repeat title lines (NRTTITLE)" do
      table = parse <<-XML
        <GPOTABLE>
          <TTITLE>Title 1</TTITLE>
          <NRTTITLE>Title 2</NRTTITLE>
        </GPOTABLE>
      XML

      expect(table.captions.map(&:body)).to eql(["Title 1","Title 2"])
    end

    it "handles headnote lines (TDESC)" do
      table = parse <<-XML
        <GPOTABLE>
          <TTITLE>Title 1</TTITLE>
          <TDESC>Description</TDESC>
        </GPOTABLE>
      XML

      expect(table.captions.map(&:body)).to eql(["Title 1","Description"])
      expect(table.captions.map(&:type)).to eql([:title, :headnote])
    end

    it "adds formatting" do
      table = parse <<-XML
        <GPOTABLE>
          <TTITLE><E T="03">New</E> title</TTITLE>
        </GPOTABLE>
      XML

      expect(table.captions.first.body).to eql("<em>New</em> title")
    end

    it "handles empty TTITLE" do
      table = parse <<-XML
        <GPOTABLE>
          <TTITLE></TTITLE>
        </GPOTABLE>
      XML

      expect(table.captions).to be_empty
    end

    it "handles missing TTITLE" do
      table = parse <<-XML
        <GPOTABLE>
        </GPOTABLE>
      XML

      expect(table.captions).to be_empty
    end
  end
end
