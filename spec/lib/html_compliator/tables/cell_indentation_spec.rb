require File.dirname(__FILE__) + '/../../../spec_helper'

describe HtmlCompilator::Tables do
  def parse(xml)
    HtmlCompilator::Tables::Table.new(
      Nokogiri::XML(xml).root
    )
  end

  context "Table cell indentation" do
    it "follows identation rules in lookup table" do
       HtmlCompilator::Tables::BodyCell::INDENTATION_RULES.each do |i_value, (indentation, hanging)|
        table = parse <<-XML
          <GPOTABLE COLS="2" CDEF="1,1">
            <ROW><ENT I="#{sprintf '%02d', i_value}">A</ENT><ENT>B</ENT></ROW>
          </GPOTABLE>
        XML
        stub_cell = table.body_rows.first.cells.first
        calculated_indentation = stub_cell.primary_indentation
        expect(calculated_indentation).to eql(indentation),
          "<ROW I=#{sprintf '%02d', i_value}> should lead to primary indentation of #{indentation} but was #{calculated_indentation}"

        calculated_hanging = stub_cell.hanging_indentation
        expect(calculated_hanging).to eql(hanging),
          "<ROW I=#{sprintf '%02d', i_value}> should lead to hanging value of #{hanging} but was #{calculated_hanging}"
      end
    end
  end
end
