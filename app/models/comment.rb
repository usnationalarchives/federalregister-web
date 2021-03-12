class Comment < ApplicationRecord
  has_one :subscription
  extend Memoist

  include EncryptionUtils
  ALLOWED_EXTENSIONS = ["bmp", "docx", "gif", "jpg", "jpeg", "pdf", "png", "pptx", "rtf", "sgml", "tif", "tiff", "txt" , "wpd", "xlsx", "xml"]
  MAX_FILE_SIZE = 10_485_760
  MAX_ATTACHMENTS = 20

  AGENCY_POSTING_GUIDELINES_LEXICON = {
    'FOR FURTHER INFORMATION CONTACT' => "<a href=\'#further-info\'>FOR FURTHER INFORMATION CONTACT</a>",
    'ADDRESSES' => "<a href=\'#addresses\'>ADDRESSES</a>",
  }

  attr_accessor :secret, :confirm_submission, :response
  attr_reader :attachments, :comment_form, :followup_document_notification

  validates_presence_of :document_number, :comment_tracking_number

  # validates_inclusion_of :confirm_submission,
  #   :in => [true, 1, "1"],
  #   :message => "You must confirm the above statement."

  validates_presence_of :document_number

  def document
    raise "Document number missing!" unless document_number.present?
    @document ||= DocumentDecorator.decorate(Document.find(document_number))
  end

  def build_subscription(user, request)
    self.subscription = Subscription.new.tap do |s|
      s.search_conditions = {:citing_document_numbers => document_number }
      s.user_id = user.id
      s.requesting_ip = request.remote_ip
      s.environment = Rails.env
      s.search_type = 'Entry'
    end
  end

  def regulations_dot_gov_document_id
    document.regulations_dot_gov_info["document_id"]
  end

  def attributes=(attrs)
    attrs.select{|k,v| respond_to?("#{k}=")}.each do |k,v|
      self.send("#{k}=",v)
    end
  end

  def respond_to?(name, include_private = false)
    attr_name = normalize_attribute(name)
    comment_form.try(:has_field?, attr_name) || super
  end

  def user
    if user_id
      User.find(user_id)
    end
  end
  memoize :user

  def add_error(error)
    errors.add(:base, error)
  end


  private

  # fix calls to "#{attr_name}_before_type_cast"
  def method_missing(name, *val)
    attr_name = normalize_attribute(name)
    if respond_to?( attr_name )
      self.send attr_name
    else
      super
    end
  end

  def normalize_attribute(name)
    name.to_s.sub(/(?:_before_type_cast)?=?$/,'')
  end
end
