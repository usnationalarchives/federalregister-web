class DocumentSubscriptionQueuePopulator
  @queue = :subscriptions
  attr_reader :date

  def self.perform(date)
    ActiveRecord::Base.verify_active_connections!
    
    new(date).enqueue_subscriptions
  end

  def initialize(date)
    @date = date
  end

  def enqueue_subscriptions
    options = ENV['FORCE_DELIVERY'].present? ? {force_delivery: ENV['FORCE_DELIVERY']} : {}

    MailingList::Document.active.find_each do |mailing_list|
      Resque.enqueue(MailingList::Document, mailing_list.id, date, options)
    end
  end
end
