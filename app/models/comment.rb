class Comment < ApplicationRecord
  has_one :subscription
  extend Memoist

  include EncryptionUtils
  MAX_ATTACHMENTS = 20

  AGENCY_POSTING_GUIDELINES_LEXICON = {
    'FOR FURTHER INFORMATION CONTACT' => "<a href=\'#further-info\'>FOR FURTHER INFORMATION CONTACT</a>",
    'ADDRESSES' => "<a href=\'#addresses\'>ADDRESSES</a>",
  }

  # TODO: Determine whether we care to persist comment data
  # before_create :persist_comment_data
  # TODO: implement delete_attachments
  #after_create :delete_attachments

  attr_accessor :secret, :confirm_submission, :response
  attr_reader :attachments, :comment_form, :followup_document_notification

  #TODO: Determine what validations are necessary in a V4 world since we've disabled all existing validations.
  # validate :required_fields_are_present
  # validate :fields_do_not_exceed_maximum_length
  # validate :not_too_many_attachments
  # validate :attachments_are_uniquely_named
  # validate :all_attachments_could_be_found

  # validates_inclusion_of :confirm_submission,
  #   :in => [true, 1, "1"],
  #   :message => "You must confirm the above statement."

  validates_presence_of :document_number

  def document
    raise "Document number missing!" unless document_number.present?
    @document ||= DocumentDecorator.decorate(Document.find(document_number))
  end

  def attachments
    @attachments ||= []
  end

  def comment_form=(comment_form)
    self.agency_name = comment_form.agency_name
    @comment_form = comment_form

    comment_form.fields.each do |field|
      self.class.send :attr_accessor, field.name.to_sym
    end
  end

  def attachment_tokens=(tokens)
    @missing_attachments = []
    @attachments = []
    if comment_form.allow_attachments?
      tokens.each do |token|
        attachment = CommentAttachment.find_by_token(token)

        if attachment
          attachment.secret = secret
          @attachments << attachment
        else
          @missing_attachments << token
        end
      end
    end

    @attachments.compact!
  end

  def comment_data
    JSON.parse(decrypt(encrypted_comment_data))
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

  # generates a stub submission key until these are returned from regulations.gov
  # non-participating agencies don't have comment tracking numbers but we want
  # to give users a way to reference thier comment in help tickets, etc.
  def add_submission_key
    update_attribute(:submission_key, "FR2-#{SecureRandom.hex}")
  end


  private

  def persist_comment_data
    comment_attrs = comment_form.fields.map(&:name).inject({}){|hsh, n| hsh[n] = self.send(n); hsh}
    comment_data = comment_form.humanize_form_data(comment_attrs)
    comment_data << {:label => "Uploaded Files", :values => attachments.map(&:original_file_name)}

    self.encrypted_comment_data = encrypt(comment_data.to_json)
  end

  def attachments_are_uniquely_named
    unless attachments.size == attachments.map(&:original_file_name).uniq.size
      errors.add(:base, "Attachments must be uniquely named")
    end
  end

  def required_fields_are_present
    comment_form.fields.select(&:required?).each do |field|
      if self.send(field.name).blank?
        errors.add(field.name, "You can't leave this field blank")
      end
    end
  end

  def not_too_many_attachments
    if attachments.size > MAX_ATTACHMENTS
      errors.add :base, "Cannot have more than #{MAX_ATTACHMENTS} attachments"
    end
  end

  def all_attachments_could_be_found
    unless @missing_attachments.blank?
      errors.add :base, "One or more of your attachments could not be found; please re-upload."
    end
  end

  def fields_do_not_exceed_maximum_length
    comment_form.text_fields.each do |field|
      val = self.send(field.name)
      if val.present? && field.max_length && val.length > field.max_length
        errors.add(field.name, "cannot exceed #{field.max_length} characters")
      end
    end
  end

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
