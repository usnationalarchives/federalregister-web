class Subscription < ApplicationModel
  attr_accessible :email, :search_conditions, :search_type
  default_scope :conditions => { :environment => Rails.env }

  before_create :generate_token
  after_create :remove_from_bounce_list

  before_save :update_mailing_list_active_subscriptions_count

  attr_accessor :search_conditions, :search_type

  belongs_to :mailing_list
  belongs_to :comment

  validates_presence_of :requesting_ip, :mailing_list, :environment

  def mailing_list_with_autobuilding
    if mailing_list_without_autobuilding.nil?
      klass = search_type == 'PublicInspectionDocument' ? MailingList::PublicInspectionDocument : MailingList::Document
      self.search_conditions ||= {}
      self.mailing_list = klass.find_by_parameters(search_conditions.to_json) || klass.new(:parameters => search_conditions)
    else
      mailing_list_without_autobuilding
    end
  end
  alias_method_chain :mailing_list, :autobuilding

  def self.not_delivered_on(date)
    scoped(:conditions => ["subscriptions.last_issue_delivered IS NULL OR subscriptions.last_issue_delivered < ?", date])
  end

  def self.confirmed
    where("subscriptions.confirmed_at IS NOT NULL")
  end

  def self.unconfirmed
    where(:confirmed_at => nil)
  end

  def public_inspection_search_possible?
    Search::PublicInspection.new(search_conditions).valid_search?
  end

  def to_param
    token
  end

  def active?
    unsubscribed_at.nil? && deleted_at.nil?
  end

  def email_from_fr_profile
    Ecfr::UserEmailResultSet.get_user_emails(user_id).values.last
  end

  def was_active?
    confirmed_at_was.present? && unsubscribed_at_was.nil? && deleted_at_was.nil?
  end

  def confirm!
    self.confirmed_at = Time.current
    self.unsubscribed_at = nil
    self.save!
  end

  def unsubscribe!
    unless self.unsubscribed_at
      self.unsubscribed_at = Time.current
      self.save!
    end
  end


  private

  def remove_from_bounce_list
    begin
      SendgridClient.new.remove_from_bounce_list(email)
    rescue StandardError => e
      Honeybadger.notify(e)
    end
  end

  def generate_token
    self.token = SecureRandom.hex(20)
  end

  def update_mailing_list_active_subscriptions_count
    if was_active? && ! active?
      MailingList.decrement_counter(:active_subscriptions_count, mailing_list_id)
    elsif !was_active? && active?
      MailingList.increment_counter(:active_subscriptions_count, mailing_list_id)
    end

    true
  end

  def self.document_subscriptions
    scoped(:include => :mailing_list,
           :conditions => {:mailing_lists => {:type => "MailingList::Document"}})
  end

  def self.pi_subscriptions
    scoped(:include => :mailing_list,
           :conditions => {:mailing_lists => {:type => "MailingList::PublicInspectionDocument"}})
  end
end
