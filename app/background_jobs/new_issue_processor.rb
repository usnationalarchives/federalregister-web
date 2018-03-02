class NewIssueProcessor < IssueProcessor
  @queue = :issue_processor

  def perform
    ActiveRecord::Base.verify_active_connections!
    
    compile_all_html
    expire_cache

    # used to avoid thundering herd after clearing sitewide cache
    sleep(60)

    deliver_mailing_lists
  end

  private

  def expire_cache
    purge_cache(".*")
  end

  def deliver_mailing_lists
    DocumentSubscriptionQueuePopulator.perform(date)
  end
end
