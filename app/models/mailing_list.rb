class MailingList < ApplicationModel
  has_many :subscriptions
  has_many :active_subscriptions,
           :class_name => "Subscription",
           :conditions => "subscriptions.confirmed_at IS NOT NULL and subscriptions.unsubscribed_at IS NULL"
  scope :active,
    :conditions => "active_subscriptions_count > 0"
  scope :for_entries,
    :conditions => {:search_type => 'Entry'}
  scope :for_public_inspection_documents,
    :conditions => {:search_type => 'PublicInspectionDocument'}

  before_create :persist_title
  serialize :parameters, JSON

  def title
    self['title'] || model.search_metadata(parameters.merge(:metadata_only => '1')).description
  end
  
  def persist_title
    self.title = title
  end
end
