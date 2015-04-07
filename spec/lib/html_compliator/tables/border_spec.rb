require File.dirname(__FILE__) + '/../../../spec_helper'

describe HtmlCompilator::Tables do
  def parse(xml)
    HtmlCompilator::Tables::Table.new(
      Nokogiri::XML(xml).root
    )
  end

  context "Table borders" do
    context "table header" do
      let(:table) do
        parse <<-XML
          <GPOTABLE COLS="3" OPTS="L2(1)" CDEF="1,1,1">
            <BOXHD>
              <CHED H="1">A</CHED>
              <CHED H="1">B</CHED>
              <CHED H="2">BA</CHED>
              <CHED H="2">BB</CHED>
            </BOXHD>
          </GPOTABLE>
        XML
      end

      it "parses simple rows" do
        expect(table.header_rows.first.cells.map(&:border_classes)).to eql([
          %w(border-top-single border-bottom-single border-right-single),
          %w(border-top-single border-bottom-single),
        ])
      end

      it "handles rows after rowspans" do
        expect(table.header_rows.second.cells.map(&:border_classes)).to eql([
          %w(border-bottom-single border-right-single),
          %w(border-bottom-single ),
        ])
      end
    end

    context "table body" do
      context "reads the alignment from the table OPTS attributes" do
        it "handles L2 format" do
          table = parse <<-XML
            <GPOTABLE COLS="3" OPTS="L2" CDEF="1,1,1">
              <ROW>
                <ENT>A</ENT>
                <ENT>B</ENT>
                <ENT>C</ENT>
              </ROW>
              <ROW>
                <ENT>A</ENT>
                <ENT>B</ENT>
                <ENT>C</ENT>
              </ROW>
            </GPOTABLE>
          XML

          expect(table.body_rows.map{|r| r.cells.map(&:border_classes)}).to eql([
            [
              %w(border-right-single),
              %w(border-right-single),
              %w(),
            ],
            [
              %w(border-bottom-single border-right-single),
              %w(border-bottom-single border-right-single),
              %w(border-bottom-single ),
            ]
          ])
        end

        it "handles L4 format" do
          table = parse <<-XML
            <GPOTABLE OPTS="L4" CDEF="1,1,1">
              <ROW>
                <ENT>A</ENT>
                <ENT>B</ENT>
                <ENT>C</ENT>
              </ROW>
              <ROW EXPSTB="00">
                <ENT>A</ENT>
                <ENT>B</ENT>
                <ENT>C</ENT>
              </ROW>
            </GPOTABLE>
          XML

          expect(table.body_rows.map{|r| r.cells.map(&:border_classes)}).to eql([
            [
              %w(border-left-single border-right-single),
              %w(border-right-single),
              %w(border-right-single),
            ],
            [
              %w(border-bottom-single border-left-single border-right-single),
              %w(border-bottom-single border-right-single),
              %w(border-bottom-single border-right-single),
            ]
          ])
        end
      end
    end
    context "reads from the ROW RUL attribute" do
      let(:table) do
        parse <<-XML
          <GPOTABLE COLS="4">
            <ROW RUL="n,s,d,b">
              <ENT>A</ENT>
              <ENT>B</ENT>
              <ENT>C</ENT>
              <ENT>D</ENT>
            </ROW>
            <ROW RUL="n,s">
              <ENT>A</ENT>
              <ENT>B</ENT>
              <ENT>C</ENT>
              <ENT>D</ENT>
            </ROW>
            <ROW RUL="s,d&amp;sqdrt;">
              <ENT>A</ENT>
              <ENT>B</ENT>
              <ENT>C</ENT>
              <ENT>D</ENT>
            </ROW>
          </GPOTABLE>
        XML
      end

      it "handles handles all four formats" do
        expect(table.body_rows.first.cells.map(&:border_bottom)).to eql [
          nil,
          :single,
          :double,
          :bold
        ]
      end

      it "defaults to no border if unspecified" do
        expect(table.body_rows.second.cells.map(&:border_bottom)).to eql [
          nil,
          :single,
          nil,
          nil
        ]
      end

      it "handles right quad entity as repeater" do
        expect(table.body_rows.third.cells.map(&:border_bottom)).to eql [
          :single,
          :double,
          :double,
          :double,
        ]
      end
    end
  end
end
