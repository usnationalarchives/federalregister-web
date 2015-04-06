require File.dirname(__FILE__) + '/../../../spec_helper'

describe HtmlCompilator::Tables do
  def parse(xml)
    HtmlCompilator::Tables::Table.new(
      Nokogiri::XML(xml).root
    )
  end

  context "Table alignment" do
    context "table body" do
      it "reads the alignment from the A attributes" do
        table = parse <<-XML
          <GPOTABLE>
            <ROW>
              <ENT>Center</ENT>
              <ENT A="0">Center</ENT>
              <ENT A="L0">Left</ENT>
              <ENT A="R0">Right</ENT>
              <ENT A="J0">Justify</ENT>
          </GPOTABLE>
        XML

        expect(table.body_rows.first.cells.map(&:alignment)).to eql([:center, :center, :left, :right, :justify])
      end
    end
  end
end
