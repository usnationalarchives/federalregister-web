class HtmlCompilator::Hyperlinks < HtmlCompilator
  attr_reader :document

  def self.perform(document)
    new(document, document.publication_date).perform
  end

  def perform
    begin
      save(compile)
    rescue MissingXmlFile => error
      Honeybadger.notify(error)
    end
  end

  def compile
    if File.exists? file_path
      Hyperlinker.perform(File.read(file_path))
    else
      raise MissingXmlFile, file_path
    end
  end

  def save(xml)
    File.open file_path, 'w' do |f|
      f.write(xml)
    end
  end

  private

  def file_path
    document_xml_path('full_text')
  end
end
