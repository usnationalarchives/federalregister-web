require "active_support/core_ext/integer/time"
require_relative "../../lib/json_logger"

# Settings specified here will take precedence over those in config/application.rb
Rails.application.configure do
  # Code is not reloaded between requests
  config.cache_classes = true

  config.eager_load = true

  # Full error reports are disabled
  config.consider_all_requests_local       = false
  # Turn off rack-cache as we set the expires header and use varnish for cache
  config.action_controller.perform_caching = false

  HTTParty::HTTPCache.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Configure SSL options to enable HSTS with subdomains.
  Rails.application.config.ssl_options = {
    redirect: false,
    hsts: { subdomains: true }
  }

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :debug

  # override default tagged logging
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = JsonLogger.new
  config.logger = logger

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  smtp_settings = {
    address: "smtp.sendgrid.net",
    port: "587",
    domain: "#{Settings.app_url}",
    user_name: Rails.application.secrets[:sendgrid][:username],
    password: Rails.application.secrets[:sendgrid][:password],
    authentication: :plain,
    enable_starttls_auto: false
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = smtp_settings

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = [I18n.default_locale]

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end

Rails.application.routes.default_url_options = {
  host: "#{Settings.app_url.gsub('https://', '')}",
  protocol: "https://"
}
