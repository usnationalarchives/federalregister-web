require File.dirname(__FILE__) + '/../../../spec_helper'

describe HtmlCompilator::Tables do
  def parse(xml)
    HtmlCompilator::Tables::Table.new(
      Nokogiri::XML(xml).root
    )
  end

  context "basic header structure" do
    let(:table) do
      parse <<-XML
        <GPOTABLE COLS="5" CDEF="6,6,6,6,6">
          <BOXHD>
            <CHED H="1"/>
            <CHED H="1">Mango</CHED>
            <CHED H="2">Production</CHED>
            <CHED H="2">Exports</CHED>
            <CHED H="1">Pineapple</CHED>
            <CHED H="2">Production</CHED>
            <CHED H="2">Exports</CHED>
          </BOXHD>
        </GPOTABLE>
      XML
    end

    it "generates the correct number of header rows" do
      expect(table.header_rows.size).to eql 2
    end

    it "the cells span the appropriate number of rows" do
      expect(
        table.header_rows.map{|r| r.cells.map(&:rowspan)}
      ).to eql [ [2,1,1], [1,1,1,1] ]
    end

    it "the cells span the appropriate number of columns" do
      expect(
        table.header_rows.map{|r| r.cells.map(&:colspan)}
      ).to eql [ [1,2,2], [1,1,1,1] ]
    end
  end

  context "crazy header structure" do
    let(:table) do
      parse <<-XML
        <GPOTABLE COLS="6" CDEF="6,6,6,6,6,6">
          <BOXHD>
            <CHED H="1">A</CHED>
            <CHED H="1">B</CHED>
            <CHED H="2">C</CHED>
            <CHED H="4">D</CHED>
            <CHED H="4">E</CHED>
            <CHED H="2">F</CHED>
            <CHED H="3">G</CHED>
            <CHED H="4">H</CHED>
            <CHED H="4">I</CHED>
          </BOXHD>
        </GPOTABLE>
      XML
    end

    it "the cells span the appropriate number of rows" do
      expect(
        table.header_rows.map{|r| r.cells.map(&:rowspan)}
      ).to eql [
        [4,1],
        [2,1],
        [1],
        [1, 1, 1, 1]
      ]
    end

    it "the cells span the appropriate number of columns" do
      expect(
        table.header_rows.map{|r| r.cells.map(&:colspan)}
      ).to eql [
        [1, 4],
        [2, 2],
        [2],
        [1, 1, 1, 1]
      ]
    end
  end

  it "ignores extra headers" do
    table = parse(<<-XML)
      <GPOTABLE COLS="2" CDEF="6,6">
        <BOXHD>
          <CHED H="1">A</CHED>
          <CHED H="1">B</CHED>
          <CHED H="1">C</CHED>
        </BOXHD>
      </GPOTABLE>
    XML
    expect(table.header_rows.first.cells.map(&:body)).to eql %w(A B)
  end

  context "basic body" do
    let(:table) do
      parse <<-XML
        <GPOTABLE CDEF="6,6,6,6">
          <ROW>
            <ENT>A</ENT>
            <ENT>B</ENT>
            <ENT>C</ENT>
            <ENT>D</ENT>
          </ROW>
          <ROW>
            <ENT>A</ENT>
            <ENT>B</ENT>
            <ENT>C</ENT>
            <ENT>D</ENT>
          </ROW>
        </GPOTABLE>
      XML
    end

    it "has the correct number of rows" do
      expect(table.body_rows.size).to eql(2)
    end

    it "the cells don't have any complexity" do
      expect(table.body_rows.map{|r| r.cells.map(&:colspan)}).
        to eql [[1,1,1,1],[1,1,1,1]]
      expect(table.body_rows.map{|r| r.cells.map(&:rowspan)}).
        to eql [[1,1,1,1],[1,1,1,1]]
    end
  end

  context "Body colspans; (A 'spanner designators')" do
    let(:table) do
      parse <<-XML
        <GPOTABLE CDEF="6,6,6">
          <ROW>
            <ENT>A</ENT>
            <ENT A="1">BC</ENT>
            <ENT>D</ENT>
          </ROW>
          <ROW>
            <ENT>A</ENT>
            <ENT A="R2">BCD</ENT>
          </ROW>
        </GPOTABLE>
      XML
    end

    it "supports integer values for A" do
      expect(table.body_rows.first.cells.map(&:colspan)).
        to eql [1,2,1]
    end

    it "supports values for A that begin with a L/R/J" do
      expect(table.body_rows.second.cells.map(&:colspan)).
        to eql [1,3]
    end
  end

  context "Body centerheads across entire table I=28" do
    let(:table) do
      parse <<-XML
        <GPOTABLE COLS="4" CDEF="6,6,6,6">
          <ROW>
            <ENT I="28">ABCD</ENT>
          </ROW>
          <ROW>
            <ENT>A</ENT>
            <ENT>B</ENT>
            <ENT>C</ENT>
            <ENT>D</ENT>
          </ROW>
        </GPOTABLE>
      XML
    end

    it "makes the cell with I=28 expand to the width of the table" do
      expect(table.body_rows.first.cells.first.colspan).to eql(4)
    end

    it "doesn't affect the colspan of other cells" do
      expect(table.body_rows.last.cells.map(&:colspan)).to eql [1,1,1,1]
    end
  end

  context "support for expanded stub body columns (EXPSTB)" do
    let(:table) do
      parse <<-XML
        <GPOTABLE CDEF="6,6,6,6">
          <ROW EXPSTB="2">
            <ENT>ABC</ENT>
            <ENT>D</ENT>
          </ROW>
          <ROW>
            <ENT>ABC</ENT>
            <ENT>D</ENT>
          </ROW>
          <ROW>
            <ENT>ABC</ENT>
            <ENT>D</ENT>
          </ROW>
          <ROW EXPSTB="0">
            <ENT>A</ENT>
            <ENT>B</ENT>
            <ENT>C</ENT>
            <ENT>D</ENT>
          </ROW>
        </GPOTABLE>
      XML
    end

    it "makes the stub column expand into additional columns when specified" do
      expect(table.body_rows.first.cells.first.colspan).to eql(3)
    end

    it "doesn't affect the colspan of the non-stub columns" do
      expect(table.body_rows.first.cells.last.colspan).to eql(1)
    end

    it "persists the stub column expansions if not specified" do
      expect(table.body_rows.third.cells.first.colspan).to eql(3)
    end

    it "resets the stub column if re-specified" do
      expect(table.body_rows.last.cells.first.colspan).to eql(1)
    end
  end
end
