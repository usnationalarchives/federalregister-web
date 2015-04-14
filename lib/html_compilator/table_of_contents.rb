class HtmlCompilator::TableOfContents < HtmlCompilator
  attr_reader :document

  def self.perform(document)
    @document = document
    new(document, document.publication_date).perform
  end

  def self.compile(document)
    @document = document
    new(document, document.publication_date).compile
  end

  def html_type
    'table_of_contents'
  end

  def xml_type
    'full_text'
  end

  def xslt_template
    "matchers/table_of_contents.html.xslt"
  end

  def xslt_variables
    {}
  end
end
