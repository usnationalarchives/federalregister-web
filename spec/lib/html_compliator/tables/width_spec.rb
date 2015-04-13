require File.dirname(__FILE__) + '/../../../spec_helper'

describe HtmlCompilator::Tables do
  def parse(xml)
    HtmlCompilator::Tables::Table.new(
      Nokogiri::XML(xml).root
    )
  end

  context "Table width" do
    context "column widths" do
      it "reads the widths from the CDEF attribute" do
        table = parse <<-XML
          <GPOTABLE CDEF="1,1,2,4"></GPOTABLE>
        XML

        expect(table.columns.map(&:percentage_width)).to eql [
          0.125,
          0.125,
          0.25,
          0.5
        ]
      end
    end
  end
end
