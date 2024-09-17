module SlackHelper
  def notify_slack!(message:, username:, channel: "#federalregister")
    if Settings.app.slack.notifications.enabled
      notifier = Slack::Notifier.new(
        Rails.application.credentials.dig(:slack, :webhook_url)
      ) do
        defaults channel: channel,
          username: username

      end

      notifier.ping message
    end
  end
end
