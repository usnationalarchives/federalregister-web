class NewIssueProcessor < IssueProcessor

  sidekiq_options :queue => :issue_processor, :retry => 0

  def perform(date)
    ActiveRecord::Base.clear_active_connections!
    @date = date

    compile_all_html
    expire_cache

    # used to avoid thundering herd after clearing sitewide cache
    sleep(60)

    deliver_mailing_lists
    update_sitemap!
  end

  private

  def expire_cache
    purge_cache(".*")
  end

  def deliver_mailing_lists
    DocumentSubscriptionQueuePopulator.new.perform(date)
  end

  def update_sitemap!
    Rails.application.load_tasks
    Rake::Task['sitemap:refresh'].invoke
  end

end
