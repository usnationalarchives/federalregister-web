class IssueReprocessor < IssueProcessor

  sidekiq_options :queue => :issue_reprocessor, :retry => 0

  def perform(date)
    ActiveRecord::Base.clear_active_connections!
    @date = date

    compile_all_html
    expire_cache
  end

  private

  def expire_cache
    purge_cache("/documents/#{date.to_s}")
    purge_cache("/documents/#{date.to_s}/*")
  end
end
