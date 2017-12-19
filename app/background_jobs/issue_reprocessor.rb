class IssueReprocessor < IssueProcessor
  @queue = :issue_reprocessor

  def perform
    compile_all_html
    expire_cache
  end

  private

  def expire_cache
    purge_cache("/documents/#{date.to_s}")
    purge_cache("/documents/#{date.to_s}/*")
  end
end
