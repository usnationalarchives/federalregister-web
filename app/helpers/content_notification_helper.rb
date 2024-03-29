module ContentNotificationHelper
  def notification(content_notification)
    wrapper_classes = ["content-notification", content_notification.type]
    wrapper_classes << content_notification.options[:html][:class] if content_notification.options[:html]

    wrapper_classes << "hidden" if content_notification.hidden

    render partial: "shared/notification", locals: {
      content_notification: content_notification,
      wrapper_classes: wrapper_classes.join(" ")
    }
  end
end
