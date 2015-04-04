class TableXmlExtractor < HtmlCompilator
  def self.compile(document_numbers, date_str)
    date = Date.parse(date_str)
    document_numbers.each do |document_number|
      new(document_number, date).perform
    end
  end

  attr_reader :document_number, :date

  def initialize(document_number, date)
    @document_number = document_number
    @date = date
  end

  def perform
    file = File.open(document_xml_path)
    document = Nokogiri::XML(file)

    tables = document.css('GPOTABLE')
    Dir.glob("#{table_xml_dir}/*.xml").each{|x| File.unlink(x) }

    if tables.present?
      FileUtils.mkdir_p(table_xml_dir)
      tables.each_with_index do |table_node, i|
        File.open(table_xml_path(i), 'w'){|f| f.write(table_node.to_xml) }
      end
    end
  end

  private

  def table_xml_dir
    [
      federalregister_api_core_data_dir,
      'tables',
      'xml',
      date.strftime("%Y/%m/%d"),
      document_number
    ].join("/")
  end

  def table_xml_path(i)
    "#{table_xml_dir}/#{i+1}.xml"
  end
end
