require File.dirname(__FILE__) + '/../../../spec_helper'

describe HtmlCompilator::Tables do
  def parse(xml)
    HtmlCompilator::Tables::Table.new(
      Nokogiri::XML(xml).root
    )
  end

  context "transformation of body cell text" do
    let(:table) do
      parse <<-XML
        <GPOTABLE CDEF="6,6,6,6">
          <ROW>
            <ENT>A</ENT>
            <ENT>B <E T="03">strong</E> young one</ENT>
            <ENT>C<AC T="8"/></ENT>
            <ENT></ENT>
          </ROW>
        </GPOTABLE>
      XML
    end

    it "passes regular text through unchanged" do
      expect(table.body_rows.first.cells.first.body).to eql 'A'
    end

    it "adds basic typeface formatting" do
      expect(table.body_rows.first.cells.second.body).to eql 'B <em>strong</em> young one'
    end

    it "is marked as HTML-safe" do
      expect(table.body_rows.first.cells.second.body).to be_html_safe
    end

    it "adds diacriticals" do
      expect(table.body_rows.first.cells.third.body).to eql 'C&#772;'
    end

    it "handles empty nodes" do
      expect(table.body_rows.first.cells.fourth.body).to eql ''
    end
  end

  context "transformation of header cell text" do
    let(:table) do
      parse <<-XML
        <GPOTABLE COLS="2" CDEF="6,6">
          <BOXHD>
            <CHED H="1"><E T="03">strong</E> disagreement</CHED>
            <CHED H="1">First Line<LI>Second Line</LI></CHED>
          </ROW>
        </GPOTABLE>
      XML
    end

    it "performs transformation" do
      expect(table.header_rows.first.cells.first.body).to eql '<em>strong</em> disagreement'
    end

    it "inserts a space around <LI> (linebreak) tags" do
      expect(table.header_rows.first.cells.second.body).to eql 'First Line Second Line'
    end
  end
end
