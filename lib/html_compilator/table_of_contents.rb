class HtmlCompilator::TableOfContents < HtmlCompilator
  attr_reader :document

  def self.compile(document, save=true)
    @document = document

    compilator = new(document, document.publication_date)
    save ? compilator.perform : compilator.compile
  end

  def type
    'full_text'
  end

  def xslt_template
    "matchers/table_of_contents.html.xslt"
  end

  def xslt_variables
    {}
  end
end
