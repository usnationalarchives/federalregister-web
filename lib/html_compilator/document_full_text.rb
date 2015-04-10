class HtmlCompilator::DocumentFullText < HtmlCompilator
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
    "matchers/full_text.html.xslt"
  end

  def xslt_variables
    {
      'first_page' => (document.start_page.to_s),
      'document_number' => document.document_number,
      'publication_date' => document.publication_date.to_s(:iso)
    }
  end
end
