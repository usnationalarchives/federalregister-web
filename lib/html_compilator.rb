class HtmlCompilator
  class MissingXmlFile < StandardError; end

  attr_reader :date, :document

  delegate :document_folder_path, :document_html_path, :document_xml_path,
    to: :path_manager

  def initialize(document, date)
    @document = document
    @date = date
  end

  def perform
    begin
      save(compile)
    rescue MissingXmlFile => error
      Honeybadger.notify(error)
    end
  end

  def compile
    if File.exists? document_xml_path(type)
      XsltTransform.standardized_html(
        XsltTransform.transform_xml(
          File.read(document_xml_path(type)),
          xslt_template,
          xslt_variables
        ).to_xml
      )
    else
      raise MissingXmlFile, document_xml_path(type)
    end
  end

  def save(html)
    FileUtils.mkdir_p(
      document_folder_path(type, 'html')
    )
    File.open document_html_path, 'w' do |f|
      f.write(html)
    end
  end

  def path_manager
    @path_manager ||= XsltPathManager.new(document.document_number, date)
  end

  def xslt_variables
    {}
  end
end
