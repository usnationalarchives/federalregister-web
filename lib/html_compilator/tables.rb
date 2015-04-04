class HtmlCompilator::Tables < HtmlCompilator
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
    xml_paths = Dir.glob("#{table_xml_dir}/*.xml")
    return unless xml_paths.present?

    FileUtils.mkdir_p(table_html_dir)
    Dir.glob("#{table_html_dir}/*.html").each{|x| File.unlink(x) }

    xml_paths.each do |xml_path|
      i = xml_path.split('/').last.to_i
      html_file_path = "#{table_html_dir}/#{i}.html"

      File.open(html_file_path, 'w') do |f|
        f.write HtmlCompilator::Tables::Table.compile(xml_path)
      end
    end
  end
end
