class Comment < ApplicationModel
  MAX_ATTACHMENTS = 10

  before_create :send_to_regulations_dot_gov
  after_create :delete_attachments

  attr_accessor :secret, :comment_form
  attr_reader :comment_form, :attachments

  validate :required_fields_are_present
  validate :not_too_many_attachments
  validate :attachments_are_uniquely_named
  validate :all_attachments_could_be_found

  validates_presence_of :document_number

  attr_reader :goats
  validates_presence_of :goats

  def attributes=(hsh)
    hsh.each_pair do |key, val|
      self.send("#{key}=", val)
    end

    hsh
  end

  def attachments
    @attachments ||= []
  end

  def attachment_tokens=(tokens)
    @missing_attachments = []
    @attachments = []
    if comment_form.allow_attachments?
      tokens.each do |token|
        attachment = CommentAttachment.find_by_token(token)

        if attachment
          @attachments << attachment
        else
          @missing_attachments << token
        end
      end
    end

    @attachments.compact!
  end

  private

  def attachments_are_uniquely_named
    unless attachments.size == attachments.map(&:attachment_file_name).uniq.size
      errors.add(:base, "Attachments must be uniquely named")
    end
  end

  def required_fields_are_present
    comment_form.fields.select(&:required?).each do |field|
      if @attributes[field.name].blank?
        errors.add(field.name, "cannot be blank")
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

  def method_missing(name, *val)
    attr_name = name.to_s.sub(/=$/,'')
    if @comment_form.has_field?(attr_name)
      @attributes ||= []

      if name.to_s =~ /=$/
        @attributes[attr_name] = val.first
      else
        @attributes[attr_name]
      end
    else
      super
    end
  end
end
