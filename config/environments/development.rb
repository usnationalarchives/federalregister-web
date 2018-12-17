MyFr2::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

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
  config.assets.precompile = []

  # Expands the lines which load the assets
  config.assets.debug = true

  SECRETS = YAML::load(
    ERB.new(
      File.read(
        File.join(File.dirname(__FILE__), '..', 'secrets.yml')
      )
    ).result
  )

  smtp_settings = {
   :address        => "smtp.sendgrid.net",
   :port           => "587",
   :domain         => "#{Settings.app_url}",
   :user_name      => SECRETS['sendgrid']['username'],
   :password       => SECRETS['sendgrid']['password'],
   :authentication => :plain,
   :enable_starttls_auto => false
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings   = smtp_settings


  config.action_mailer.default_url_options = {:host => "#{Settings.app_url.split('//').last}", :protocol => "http://"}

  if Settings.vcr.enabled
    file = "#{Rails.root}/#{Settings.vcr.library_dir}/#{Settings.vcr.cassette}.yml"
    raise "VCR cassette is too large! Max cassette size is #{Settings.vcr.max_cassette_size}Mb. Check the file size in #{Settings.vcr.library_dir}." if (File.size(file).to_f / 1024000) > Settings.vcr.max_cassette_size
  end
end
