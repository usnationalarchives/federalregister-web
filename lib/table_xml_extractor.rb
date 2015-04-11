class TableXmlExtractor
  delegate :document_xml_path, :table_xml_dir, :table_xml_path,
    to: :path_manager

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
    if File.exists? document_xml_path("full_text")
      file = File.open(document_xml_path("full_text"))
      document = Nokogiri::XML(file)

      tables = document.css('GPOTABLE')
      Dir.glob("#{table_xml_dir}/*.xml").each{|x| File.unlink(x) }

      if tables.present?
        FileUtils.mkdir_p(table_xml_dir)
        tables.each_with_index do |table_node, i|
          File.open(table_xml_path(i), 'w'){|f| f.write(table_node.to_xml) }
        end
      end
    else
      Honeybadger.notify(
        error_class: 'HtmlCompilator::MissingXmlFile',
        error_message: document_xml_path("full_text")
      )
    end
  end

  private

  def path_manager
    @path_manager ||= XsltPathManager.new(document_number, date)
  end
end
