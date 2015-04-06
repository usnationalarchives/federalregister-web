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
              <ENT A="L0">Left</ENT>
              <ENT A="R0">Right</ENT>
              <ENT A="J0">Justify</ENT>
            </ROW>
          </GPOTABLE>
        XML

        expect(table.body_rows.first.cells.map(&:alignment)).to eql([
          :left,
          :right,
          :justify
        ])
      end
    end

    context "it uses the column type from the GPOTABLE CDEF attribute" do
      it "works fine for basic attributes" do
        table = parse <<-XML
          <GPOTABLE CDEF="s3,r3,xl3,xs3,xls3,3,3.3,tr3">
            <ROW>
              <ENT>Stub</ENT>
              <ENT>Reading</ENT>
              <ENT>Special Reading</ENT>
              <ENT>Special Reading</ENT>
              <ENT>Special Reading</ENT>
              <ENT>Figure</ENT>
              <ENT>Alignment</ENT>
              <ENT>Tracing</ENT>
            </ROW>
          </GPOTABLE>
        XML

        expect(table.body_rows.first.cells.map(&:alignment)).to eql([
          :center,
          :center,
          :center,
          :center,
          :center,
          :right,
          :right,
          :center,
        ])
      end

      it "handles colspans" do
        table = parse <<-XML
          <GPOTABLE CDEF="s3,r3,xl3,xs3,xls3,3,3.3,tr3">
            <ROW>
              <ENT A="3">Stub</ENT>
              <ENT>Special Reading</ENT>
              <ENT A="1">Figure</ENT>
              <ENT>Tracing</ENT>
            </ROW>
          </GPOTABLE>
        XML

        expect(table.body_rows.first.cells.map(&:alignment)).to eql([
          :center,
          :center,
          :right,
          :center,
        ])
      end
    end
  end
end
