class HtmlCompilator::Hyperlinks < HtmlCompilator
  attr_reader :document

  def self.perform(document)
    new(document, document.publication_date).perform
  end

  def compile
    if File.exists? file_path
      Hyperlinker.perform(File.read(file_path), {date: date})
    else
      raise MissingXmlFile, file_path
    end
  end

  def destination_path
    document_xml_enhanced_path('full_text')
  end

  private

  def file_path
    document_xml_path('full_text')
  end
end
