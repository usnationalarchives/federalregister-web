MyFr2::Application.configure do
  APP_HOST_NAME = "127.0.0.1:8080"

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.assets.compile = true
  # Do not compress assets
  config.assets.compress = false
  config.assets.digest = false
  config.assets.prefix = "/assets"
  config.assets.precompile = []

  # Expands the lines which load the assets
  config.assets.debug = true

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

  config.action_mailer.default_url_options = {:host => "#{APP_HOST_NAME}", :protocol => "http://"}
end
