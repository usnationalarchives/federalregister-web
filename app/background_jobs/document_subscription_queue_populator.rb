class DocumentSubscriptionQueuePopulator
  include Sidekiq::Worker

  sidekiq_options :queue => :subscriptions, :retry => 0

  attr_reader :date

  def perform(date)
    return unless Settings.app.subscriptions.deliver

    @date = date

    ActiveRecord::Base.clear_active_connections!

    enqueue_subscriptions
  end

  def enqueue_subscriptions
    options = ENV['FORCE_DELIVERY'].present? ? {force_delivery: ENV['FORCE_DELIVERY']} : {}

    MailingList::Document.active.find_each do |mailing_list|
      Sidekiq::Client.enqueue(MailingListSender, mailing_list.id, date, options.stringify_keys)
    end
  end
end
