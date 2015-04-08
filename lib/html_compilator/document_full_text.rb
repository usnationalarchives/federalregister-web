class HtmlCompilator::DocumentFullText < HtmlCompilator
  def self.compile(document_numbers)
    document_numbers.each do |document_number|
      type = "full_text"
      xslt_template = "matchers/full_text.html.xslt"
      new(document_number, type, xslt_template).compile
    end
  end
end
