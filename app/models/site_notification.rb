# this is just a stubbed implementation until we implement it fully via admin
# see eCFR for full implementation example
class SiteNotification
  DEFAULT_ORDER = %w[error warning feature info basic]

  # no entry means only global and 'all' notifications will be shown
  CONTROLLER_LOCATION_MAP = {
    "DocumentsController" => "documents",
    "PublicInspectionDocumentsController" => "documents"
  }

  vattr_initialize [
    :location,
    :message,
    :notification_type,
    :skip_locations,
    :user_dismissible
  ]

  def self.all
    all = []

    if Settings.app.site_notifications.display
      generic_message = <<~HTML
        <p>
          <strong>Design Updates:</strong>
          As part of our ongoing effort to make FederalRegister.gov more
          accessible and easier to use we've made changes to our desktop and
          mobile layouts.
          <a href="/reader-aids/recent-updates/2024/07/accessibility-and-user-experience-enhancements">
            Read more in our feature announcement
          </a>.
        </p>
      HTML

      document_message = <<~HTML
        <p>
          <strong>Design Updates:</strong>
          As part of our ongoing effort to make FederalRegister.gov more
          accessible and easier to use we've enlarged the space available to the
          document content and moved all document related data into the utility
          bar on the left of the document.
          <a href="/reader-aids/recent-updates/2024/07/accessibility-and-user-experience-enhancements#user-experience-document">
            Read more in our feature announcement
          </a>.
        </p>
      HTML

      all << new(
        location: "all",
        message: generic_message,
        notification_type: "feature",
        skip_locations: ["documents"],
        user_dismissible: true
      )

      all << new(
        location: "documents",
        message: document_message,
        notification_type: "feature",
        user_dismissible: true
      )
    end
  end

  def self.site_notifications_for(controller_or_location, include_all: true)
    location = controller_or_location.is_a?(String) ?
      controller_or_location :
      CONTROLLER_LOCATION_MAP[controller_or_location.class.name]

    desired_locations = [location]
    desired_locations << "all" if include_all
    desired_locations.compact!

    all.select do |notification|
      desired_locations.include?(notification.location) &&
        !notification.skip_locations&.include?(location)
    end.sort_by { |n| DEFAULT_ORDER.index(n) }
  end

  def to_content_notification(controller=nil)
    ContentNotification.new(
      type: notification_type,
      text: message,
      options: {
        closable: user_dismissible,
        html: {
          class: "site-notification #{controller_css(controller)}"
        }
      }
    )
  end

  private

  def controller_css(controller)
    controller&.class&.name&.snakecase.gsub("_", "-")
  end
end
