# this is just a stubbed implementation until we implement it fully via admin
# see eCFR for full implementation example
class SiteNotification
  DEFAULT_ORDER = %w[error warning feature info basic]

  # no entry means only global and 'all' notifications will be shown
  CONTROLLER_LOCATION_MAP = {
    "DocumentsController" => "documents",
    "PublicInspectionDocumentsController" => "documents",
    "Search::DocumentsController" => "search"
  }

  vattr_initialize [
    :location,
    :message,
    :notification_type,
    :skip_locations,
    :user_dismissible
  ]

  def self.all
    notifications = []

    if Settings.app.site_notifications.display
      if Settings.app.site_notifications.search_filter.display
        search_message = <<~HTML
          <p>
            <strong>Search Filter Update:</strong>
            System of Records Notices (SORN) and Sunshine Act Meeting Notices are
            now available as sub-type filters when Notice is selected as a
            'Document Category' filter.
            <a href="/reader-aids/2024/08/enhanced-notice-sub-type-search-now-available">
              Read more in our feature announcement
            </a>.
          </p>
        HTML

        notifications << new(
          location: "search",
          message: search_message,
          notification_type: "feature",
          user_dismissible: true
        )
      end

      notifications
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
