class HtmlCompilator
  attr_reader :document_number, :type, :xslt_template

  def initialize(document_number, type, xslt_template)
    @document_number = document_number
    @type = type
    @xslt_template = xslt_template
  end

  def compile
    html = XsltTransform.standardized_html(
      XsltTransform.transform_xml(
        File.read(document_xml_path),
        xslt_template
      ).to_xml
    )

    FileUtils.mkdir_p(document_folder_path)
    File.open document_html_path, 'w' do |f|
      f.write(html)
    end
  end

  private

  def federalregister_api_core_data_dir
    "#{Rails.root}/../federalregister-api-core/data"
  end

  def federalregister_api_core_xml_dir
    "#{federalregister_api_core_data_dir}/xml"
  end

  def federalregister_api_core_html_dir
    "#{federalregister_api_core_data_dir}/documents/html"
  end

  def document_xml_path
    "#{federalregister_api_core_xml_dir}/#{document_file_path}.xml"
  end

  def document_html_path
    "#{federalregister_api_core_html_dir}/#{type}/#{document_file_path}.html"
  end

  def document_file_path
    document_number.sub(/-/,'').scan(/.{0,3}/).reject(&:blank?).join('/')
  end

  def document_folder_path
    parts = document_html_path.split('/')
    parts.pop
    parts.join('/')
  end
end
