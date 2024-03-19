# Only recompiles existing xml to html.
# Unlike IssueReprocessor this class does not modify any XML on disk and as so
# is not as complete.
class IssueRecompilator < IssueProcessor

  sidekiq_options :queue => :issue_recompilator, :retry => 0

  def perform(date)
    ActiveRecord::Base.clear_active_connections!
    @date = date

    compile_all_html
    expire_cache
  end

  def compile_all_html
    documents(date).each do |document|
      HtmlCompilator::DocumentFullText.perform(document)
      HtmlCompilator::TableOfContents.perform(document)
    end

    document_numbers = documents(date).map(&:document_number)
    HtmlCompilator::Tables.compile(document_numbers, date)
  end

  private

  def expire_cache
    purge_cache("/documents/#{date.to_s}")
    purge_cache("/documents/#{date.to_s}/*")
  end
end
