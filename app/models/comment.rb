class Comment < ApplicationModel
  belongs_to :user

  include EncryptionUtils
  MAX_ATTACHMENTS = 10

  before_create :send_to_regulations_dot_gov
  before_create :persist_comment_data
  # TODO: implement delete_attachments
  #after_create :delete_attachments

  attr_accessor :secret
  attr_reader :attachments, :comment_form

  validate :required_fields_are_present
  validate :fields_do_not_exceed_maximum_length
  validate :not_too_many_attachments
  validate :attachments_are_uniquely_named
  validate :all_attachments_could_be_found

  validates_presence_of :document_number

  def article
    @article ||= ArticleDecorator.decorate( FederalRegister::Article.find(self.document_number) )
  end

  def attributes=(hsh)
    hsh.keys.sort.reverse.each do |key|
      self.send("#{key}=", hsh[key])
    end

    hsh
  end

  def attachments
    @attachments ||= []
  end

  def comment_form=(comment_form)
    self.agency_name = comment_form.agency_name
    @comment_form = comment_form
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

  def send_to_regulations_dot_gov
    Dir.mktmpdir do |dir|
      args = {
        :comment_on => comment_form.document_id,
        :submit     => "Submit Comment"
      }.merge(attributes.slice(*comment_form.fields.map(&:name)))

      args[:uploadedFile] = attachments.map do |attachment|
        File.open(attachment.decrypt_to(dir))
      end

      self.comment_tracking_number = comment_form.client.submit_comment(args)

      # TODO: srm dir
    end
  end

  def comment_data
    @comment_data ||= JSON.parse(decrypt(encrypted_comment_data))
  end

  def respond_to?(name, include_private = false)
    attr_name = name.to_s.sub(/(?:_before_type_cast)?=?$/,'')
    comment_form.try(:has_field?, attr_name) || super
  end

  private

  def persist_comment_data
    @comment_data = comment_form.humanize_form_data(attributes)

    @comment_data << {:label => "Uploaded Files", :values => attachments.map(&:original_file_name)}

    self.encrypted_comment_data = encrypt(@comment_data.to_json) 
  end

  def attachments_are_uniquely_named
    unless attachments.size == attachments.map(&:original_file_name).uniq.size
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

  def fields_do_not_exceed_maximum_length
    comment_form.text_fields.each do |field|
      if field.max_length && @attributes[field.name].length > field.max_length
        errors.add(field.name, "cannot exceed #{field.max_length} characters")
      end
    end
  end

  def method_missing(name, *val)
    attr_name = name.to_s.sub(/(?:_before_type_cast)?=?$/,'')
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
