namespace :documents do
  namespace :html do
    namespace :compile do
      desc "Converts XSLT into various html representations for a set of FR document numbers"
      task :all, [:document_numbers] => %w(
        table_of_contents
        extract_table_xml
        tables
        full_text
      )

      task :full_text, [:document_numbers] => :environment do |t, args|
        documents(
          parse_document_numbers(args[:document_numbers])
        ).each do |document|
          HtmlCompilator::DocumentFullText.perform(document)
        end
      end

      task :table_of_contents, [:document_numbers] => :environment do |t, args|
        documents(
          parse_document_numbers(args[:document_numbers])
        ).each do |document|
          HtmlCompilator::TableOfContents.perform(document)
        end
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
        @doc_nums ||= doc_nums.split(';')
      end

      def documents(doc_nums)
        FederalRegister::Document.find_all(
          doc_nums,
          fields: %w(document_number publication_date start_page images)
        )
      end
    end
  end
end
