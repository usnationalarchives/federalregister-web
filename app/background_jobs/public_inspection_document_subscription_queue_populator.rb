class PublicInspectionDocumentSubscriptionQueuePopulator
  include Sidekiq::Worker

  sidekiq_options :queue => :subscriptions, :retry => 0

  attr_reader :date, :document_numbers

  def perform(document_numbers)
    return unless Settings.app.subscriptions.deliver_pil
    @document_numbers = document_numbers

    ActiveRecord::Base.clear_active_connections!

    enqueue_subscriptions
  end

  def enqueue_subscriptions
    options = ENV['FORCE_DELIVERY'].present? ? {force_delivery: ENV['FORCE_DELIVERY']} : {}
    options.merge!(document_numbers: document_numbers)

    current_datetime = Date.current.to_s(:iso)
    MailingList::PublicInspectionDocument.active.find_each do |mailing_list|
      Sidekiq::Client.enqueue(MailingListSender, mailing_list.id, current_datetime, options.stringify_keys)
    end
  end
end
