class EmailNotification
  class EmailNotificationError < StandardError; end

  NOTIFICATIONS = YAML::load_file(Rails.root.join('data', 'email_notifications.yml'))['notifications']

  def self.notifications
    @notifications ||= NOTIFICATIONS.map do |n|
      next unless n['enabled']
      next unless valid_definition?(n)

      notification =  EmailNotification.new(:category => n['category'],
                                            :created  => n['created'],
                                            :enabled  => n['enabled'],
                                            :html_content  => n['html_content'],
                                            :name     => n['name'],
                                            :subject  => n['subject'],
                                            :text_content  => n['text_content'])
      notification
    end.compact
  end

  def self.find(name, options = {})
    notification = notifications.select{|n| n.name == name}.first

    return nil unless notification
    return nil if notification.enabled == false unless options[:disabled]

    notification
  end


  attr_accessor :category, :created, :enabled, :html_content, :name, :subject, :text_content
  def initialize(args={})
    @category     = args[:category]
    @created      = args[:created]
    @enabled      = args[:enabled]
    @html_content = args[:html_content]
    @name         = args[:name]
    @subject      = args[:subject]
    @text_content = args[:text_content]
  end

  def deliver!(emails)
    EmailNotification.raise_error("Must supply and array of emails to deliver notification to.") unless emails.present?

    FRMailer.generic_notification(Array(emails), subject, html_content, text_content, category).deliver!
  end

  private

  def self.handle_missing_notifcation(notification, name)
    message = "Attempt to use missing or disabled notifcation '#{name}'"

    raise_error(message)
  end

  def self.valid_definition?(notification_definition)
    notification_definition['name'].present? &&
      notification_definition['category'].present? &&
      notification_definition['html_content'].present? &&
      notification_definition['html_content'].include?("(((email)))")
      notification_definition['text_content'].present? &&
      notification_definition['text_content'].include?("(((email)))")
      notification_definition['created'].present? &&
      notification_definition['enabled'].to_s.present? &&  #boolean value
      notification_definition['subject'].present?
  end

  def self.raise_error(message)
    if Rails.env == "production"
      Honeybadger.notify(message)
    else
      raise EmailNotificationError, message
    end
  end
end
