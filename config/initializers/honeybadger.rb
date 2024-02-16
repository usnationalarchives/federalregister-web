Honeybadger.configure do |config|
  config.api_key = Rails.application.credentials.dig(:honeybadger, :api_key)

  config.revision = Settings.container.revision

  config.before_notify << lambda do |notice|
    notice.context.merge!(
      application: "web",
      deployment_environment: Settings.container.role,
      tags: "#{Settings.container.process}_process, #{Settings.container.role}",
      revision: Settings.container.revision
    )
  end
end
