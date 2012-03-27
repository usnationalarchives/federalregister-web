MyFr2::Application.configure do
  APP_HOST_NAME = "www.federalregister.gov"
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Change path for generated assets
  config.assets.prefix = "my/assets"

  # Generate digests for assets URLs
  config.assets.digest = false

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( application-ie.css application-shared.js application-fr2.js application-ie8lte.css application-ie7lte.css )

  sendgrid_keys  = File.open( File.join(File.dirname(__FILE__), '..', 'sendgrid.yml') ) { |yf| YAML::load( yf ) }
  smtp_settings = {
   :address        => "smtp.sendgrid.net",
   :port           => "587",
   :domain         => "#{APP_HOST_NAME}",
   :user_name      => sendgrid_keys['username'],
   :password       => sendgrid_keys['password'],
   :authentication => :plain
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings   = smtp_settings

  config.action_mailer.default_url_options = {:host => "#{APP_HOST_NAME}", :script_name => '/my'}

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
