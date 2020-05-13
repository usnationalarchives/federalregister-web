class PublicInspectionDocumentSubscriptionQueuePopulator
  @queue = :subscriptions
  attr_reader :date, :document_numbers

  def self.perform(document_numbers)
    return unless Settings.feature_flags.subscriptions.deliver_pil

    ActiveRecord::Base.clear_active_connections!

    new(document_numbers).enqueue_subscriptions
  end

  def initialize(document_numbers)
    @document_numbers = document_numbers
  end

  def enqueue_subscriptions
    options = ENV['FORCE_DELIVERY'].present? ? {force_delivery: ENV['FORCE_DELIVERY']} : {}
    options.merge!(document_numbers: document_numbers)

    current_datetime = DateTime.current
    MailingList::PublicInspectionDocument.active.find_each do |mailing_list|
      Resque.enqueue(MailingListSender, mailing_list.id, current_datetime, options)
    end
  end
end
