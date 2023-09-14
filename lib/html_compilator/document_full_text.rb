class HtmlCompilator::DocumentFullText < HtmlCompilator
  attr_reader :document

  def self.perform(document)
    new(document, document.publication_date).perform
  end

  def self.compile(document)
    new(document, document.publication_date).compile
  end

  def html_type
    'full_text'
  end

  def xml_type
    'full_text'
  end

  def xslt_template
    "matchers/full_text.html.xslt"
  end

  def xslt_variables
    {
      'first_page' => (document.start_page.to_s),
      'document_number' => document.document_number,
      'publication_date' => document.publication_date.to_s(:iso),
      # create a string that is parsable later "identifier,url identifier,url"
      'images' => document.images.map{|image| "#{image.identifier},#{default_image_url(image)}"}.join(' ') || ''
    }
  end

  private

  def default_image_url(image)
    image.attributes[1]['original_size']
  end
end
