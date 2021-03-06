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
    if File.exists? document_xml_enhanced_path(xml_type)
      # BB TODO: this removes html entities which we need in the view
      # ideally we find a way for this to work but turning it off for now
      #XsltTransform.standardized_html(
        XsltTransform.transform_xml(
          File.read(document_xml_enhanced_path(xml_type)),
          xslt_template,
          xslt_variables
        ).to_xml
      #)
    else
      raise MissingXmlFile, document_xml_enhanced_path(xml_type)
    end
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
end
