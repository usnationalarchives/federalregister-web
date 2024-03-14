class HtmlCompilator
  class MissingXmlFile < StandardError; end

  attr_reader :date, :document

  delegate :document_dir, :document_html_path, :document_xml_path,
    :document_xml_enhanced_path,
    to: :path_manager

  def initialize(document, date)
    @document = document
    @date = date
  end

  def perform
    begin
      puts "#{self.class} Compiling #{document.document_number}"
      save(compile)
    rescue StandardError => error
      warn error
      Honeybadger.notify(error)
    end
  end

  def compile
    XsltTransform.transform_xml(
      xml_source,
      xslt_template,
      xslt_variables
    ).to_xml
  end

  def save(html)
    FileUtils.mkdir_p(
      File.dirname(destination_path)
    )
    File.open destination_path, 'w' do |f|
      f.write(html)
    end
  end

  def destination_path
    document_html_path(html_type)
  end

  def path_manager
    @path_manager ||= XsltPathManager.new(document.document_number, date)
  end

  def xslt_variables
    {}
  end

  private

  def xml_source
    if File.exists? document_xml_enhanced_path(xml_type)
      File.read(document_xml_enhanced_path(xml_type))
    elsif Settings.app.document_render.from_remote_raw_xml
      response = HTTParty.get(document.full_text_xml_url)
      if response.ok?
        FileUtils.mkdir_p(document_dir(xml_type, 'xml_enhanced'))
        File.write(
          document_xml_enhanced_path(xml_type),
          response.body.force_encoding(Encoding::UTF_8)
        )
        response.body
      else
        raise MissingXmlFile, document.full_text_xml_url
      end
    else
      raise MissingXmlFile, document_xml_enhanced_path(xml_type)
    end
  end
end
