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
          "<ROW I=#{sprintf '%02d', i_value}> expected primary indentation of #{indentation} but was #{calculated_indentation}"

        calculated_hanging = stub_cell.hanging_indentation
        expect(calculated_hanging).to eql(hanging),
          "<ROW I=#{sprintf '%02d', i_value}> expected hanging value of #{hanging} but was #{calculated_hanging}"
      end
    end

    [
      {override: "oi1", expected_indentation: 1, expected_hanging_indentation: nil},
      {override: "oi3", expected_indentation: 3, expected_hanging_indentation: nil},
    ].each do |scenario|
      it "follows override rules (#{scenario[:override]})" do
        table = parse <<-XML
          <GPOTABLE COLS="2" CDEF="1,1">
            <ROW><ENT O="#{scenario[:override]}">lorem</ENT><ENT>ipsum</ENT></ROW>
          </GPOTABLE>
        XML

        cell = table.body_rows.first.cells.first
        html = table.to_html
        
        if (expected_indentation = scenario[:expected_indentation])
          expect(cell.primary_indentation).to eql(expected_indentation)
          expect(html).to include("primary-indent-#{expected_indentation}")
        else
          expect(html).not_to include("primary-indent-#{expected_indentation}")
        end

        if (expected_hanging_indentation = scenario[:hanging_indentation])
          expect(cell.hanging_indentation).to eql(expected_hanging_indentation) 
          expect(html).to include("primary-indent-hanging-#{expected_hanging_indentation}")
        else
          expect(html).not_to include("primary-indent-hanging-")
        end
      end
    end
  end
end
