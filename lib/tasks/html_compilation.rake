namespace :documents do
  namespace :html do
    namespace :compile do
      desc "Converts XSLT into various html representations for a set of FR document numbers"
      task :all, [:document_numbers] => :environment do |t, args|
        Rake::Task["documents:html:compile:table_of_contents"].invoke(args[:document_numbers])
      end

      task :table_of_contents, [:document_numbers] => :environment do |t, args|
        HtmlCompilator::TableOfContents.compile(
          parse_document_numbers(args[:document_numbers])
        )
      end

      def parse_document_numbers(doc_nums)
        @doc_nums ||= doc_nums.split(" ")
      end
    end
  end
end
