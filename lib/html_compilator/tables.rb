module HtmlCompilator::Tables
  def self.compile(document_numbers)
    table_xml_files.each do |path|
      HtmlCompilator::Tables::Table.compile(path)
    end
  end
end
