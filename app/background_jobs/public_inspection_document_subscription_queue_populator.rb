class PublicInspectionDocumentSubscriptionQueuePopulator
  @queue = :subscriptions
  attr_reader :date, :document_numbers

  def self.perform(date, document_numbers)
    ActiveRecord::Base.verify_active_connections!
    
    new(date, document_numbers).enqueue_subscriptions
  end

  def initialize(date, document_numbers)
    @date = date
    @document_numbers = document_numbers
  end

  def enqueue_subscriptions
    options = ENV['FORCE_DELIVERY'].present? ? {force_delivery: ENV['FORCE_DELIVERY']} : {}

    MailingList::PublicInspectionDocument.active.find_each do |mailing_list|
      Resque.enqueue(MailingList::PublicInspectionDocument, mailing_list.id, date, document_numbers, options)
    end
  end
end
