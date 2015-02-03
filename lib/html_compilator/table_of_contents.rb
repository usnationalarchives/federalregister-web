class HtmlCompilator::TableOfContents < HtmlCompilator
  def self.compile(document_numbers)
    document_numbers.each do |document_number|
      type = "table_of_contents"
      xslt_template = "documents/table_of_contents.html.xslt"
      new(document_number, type, xslt_template).compile
    end
  end
end
