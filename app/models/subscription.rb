class Subscription < ApplicationModel
  attr_accessible :email, :search_conditions, :search_type
  default_scope :conditions => { :environment => Rails.env }
  before_create :generate_token
  after_create :remove_from_bounce_list
  before_save :update_mailing_list_active_subscriptions_count

  validates_format_of :email, :with => /\A[^ ]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+\z/, :format => "is not a valid email address"

  attr_accessor :search_conditions, :search_type

  belongs_to :mailing_list
  belongs_to :user
  belongs_to :comment

  def mailing_list_with_autobuilding
    if mailing_list_without_autobuilding.nil?
      klass = search_type == 'PublicInspectionDocument' ? MailingList::PublicInspectionDocument : MailingList::Document
      self.mailing_list = klass.find_by_parameters(search_conditions.to_json) || klass.new(:parameters => search_conditions)
    else
      mailing_list_without_autobuilding
    end
  end
  alias_method_chain :mailing_list, :autobuilding

  validates_presence_of :email, :requesting_ip, :mailing_list, :environment

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
    confirmed_at.present? && unsubscribed_at.nil?
  end

  def was_active?
    confirmed_at_was.present? && unsubscribed_at_was.nil?
  end

  def confirm!
    unless active?
      self.confirmed_at = Time.current
      self.unsubscribed_at = nil
      self.save!
    end
  end

  def unsubscribe!
    unless self.unsubscribed_at
      self.unsubscribed_at = Time.current
      self.save!
    end
  end

  def user_with_this_email_exists?
    user_with_this_email.present?
  end

  def user_with_this_email
    @user_with_this_email ||= User.where(:email => self.email).first
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

  def self.article_subscriptions
    scoped(:include => :mailing_list,
           :conditions => {:mailing_lists => {:type => "MailingList::Document"}})
  end

  def self.pi_subscriptions
    scoped(:include => :mailing_list,
           :conditions => {:mailing_lists => {:type => "MailingList::PublicInspectionDocument"}})
  end
end
