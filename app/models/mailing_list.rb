class MailingList < ApplicationModel
  BATCH_SIZE = 1000

  has_many :subscriptions

  has_many :active_subscriptions,
    class_name: "Subscription",
    conditions: "subscriptions.unsubscribed_at IS NULL and subscriptions.deleted_at IS NULL"

  scope :active, -> {
    where(deleted_at: nil).
    joins(:subscriptions).
    where( {subscriptions: {deleted_at: nil}} ).
    uniq
  }

  scope :for_entries,
    conditions: {search_type: 'Document'}

  scope :for_public_inspection_documents,
    conditions: {search_type: 'PublicInspectionDocument'}

  before_create :persist_title
  serialize :parameters, JSON

  def title
    self['title'] || model.search_metadata(conditions: parameters).description
  end

  def persist_title
    self.title = title
  end

  private

  def log_delivery(subscription_count, document_count)
    Rails.logger.info("[#{Time.now.in_time_zone}] {type: '#{self.class}', id: #{self.id}, status: 'delivered', subscriptions: #{subscription_count}, documents: #{document_count}}")
  end

  def log_no_delivery
    Rails.logger.info("[#{Time.now.in_time_zone}] {type: '#{self.class}', id: #{self.id}, status: 'no results'}")
  end
end

require_dependency 'mailing_list/document'
require_dependency 'mailing_list/public_inspection_document'
