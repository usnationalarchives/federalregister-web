namespace :documents do
  namespace :html do
    namespace :compile do
      desc "Converts XSLT into various html representations for a set of FR document numbers"
      task :all, [:date] => %w(
        hyperlinks
        table_of_contents
        extract_table_xml
        tables
        full_text
      )

      task :hyperlinks, [:date] => :environment do |t, args|
        documents(args[:date]).each do |document|
          HtmlCompilator::Hyperlinks.perform(document)
        end
      end

      task :full_text, [:date] => :environment do |t, args|
        documents(args[:date]).each do |document|
          HtmlCompilator::DocumentFullText.perform(document)
        end
      end

      task :table_of_contents, [:date] => :environment do |t, args|
        documents(args[:date]).each do |document|
          HtmlCompilator::TableOfContents.perform(document)
        end
      end

      task :extract_table_xml, [:date] => :environment do |t, args|
        TableXmlExtractor.compile(
          documents(args[:date]).map(&:document_number),
          args[:date]
        )
      end

      task :tables, [:date] => :environment do |t, args|
        HtmlCompilator::Tables.compile(
          documents(args[:date]).map(&:document_number),
          args[:date]
        )
      end

      def documents(date)
        Document.search(
          conditions: {publication_date: {is: date}},
          fields: %w(document_number publication_date start_page images),
          per_page: 1000,
          cache_buster: Time.now.to_i
        )
      end
    end
  end
end
