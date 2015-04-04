namespace :documents do
  namespace :html do
    namespace :compile do
      desc "Converts XSLT into various html representations for a set of FR document numbers"
      task :all, [:document_numbers] => %w(
        table_of_contents
        extract_table_xml
        tables
      )

      task :table_of_contents, [:document_numbers] => :environment do |t, args|
        HtmlCompilator::TableOfContents.compile(
          parse_document_numbers(args[:document_numbers])
        )
      end

      task :extract_table_xml, [:document_numbers] => :environment do |t, args|
        raise "DATE not provided via ENV" unless ENV['DATE']
        TableXmlExtractor.compile(
          parse_document_numbers(args[:document_numbers]),
          ENV['DATE']
        )
      end

      task :tables, [:document_numbers] => :environment do |t, args|
        raise "DATE not provided via ENV" unless ENV['DATE']
        HtmlCompilator::Tables.compile(
          parse_document_numbers(args[:document_numbers]),
          ENV['DATE']
        )
      end

      def parse_document_numbers(doc_nums)
        @doc_nums ||= doc_nums.split(" ")
      end
    end
  end
end
