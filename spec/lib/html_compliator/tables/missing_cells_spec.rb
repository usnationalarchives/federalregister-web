require File.dirname(__FILE__) + '/../../../spec_helper'

describe HtmlCompilator::Tables do
  def parse(xml)
    HtmlCompilator::Tables::Table.new(
      Nokogiri::XML(xml).root
    )
  end

  context "Missing cells" do
    context "table body" do
      it "adds missing cells at end of row" do
        table = parse <<-XML
          <GPOTABLE COLS="3" OPTS="L2(1)" CDEF="1,1,1">
            <ROW>
              <ENT I="22">A</ENT>
            </ROW>
          </GPOTABLE>
        XML

        expect(table.body_rows.first.cells.size).to eql(3)
      end

      it "handles colspan" do
        table = parse <<-XML
          <GPOTABLE COLS="3" OPTS="L2(1)" CDEF="1,1,1">
            <ROW>
              <ENT A="1">AB</ENT>
            </ROW>
          </GPOTABLE>
        XML

        expect(table.body_rows.first.cells.size).to eql(2)
      end
    end
  end
end
