class XsltPathManager
  attr_reader :date, :document_number

  def initialize(document_number, date)
    @document_number = document_number
    @date = date.is_a?(Date) ? date : Date.parse(date)
  end

  def document_xml_enhanced_path(type)
    "#{document_dir(type, 'xml_enhanced')}/#{document_number}.xml"
  end

  def document_xml_path(type)
    "#{document_dir(type, 'xml')}/#{document_number}.xml"
  end

  def document_html_path(type)
    "#{document_dir(type, 'html')}/#{document_number}.html"
  end

  def document_dir(type, format)
    data_dir(type, format)
  end


  def table_xml_path(index)
    "#{table_xml_dir}/#{index}.xml"
  end

  def table_html_path(index)
    "#{table_html_dir}/#{index}.html"
  end

  def table_xml_dir
    table_dir('xml')
  end

  def table_html_dir
    table_dir('html')
  end

  def table_dir(format)
    File.join(
      data_dir('tables', format),
      document_number
    )
  end

  private

  def self.shared_data_dir
    "#{Rails.root}/data/efs"
  end

  def shared_data_dir
    self.class.shared_data_dir
  end

  def document_data_path
    "#{shared_data_dir}/documents"
  end

  def data_dir(type, format)
    File.join(
      document_data_path,
      type,
      format,
      date.strftime("%Y/%m/%d")
    )
  end

end
