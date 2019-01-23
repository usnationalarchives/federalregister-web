# Settings specified here will take precedence over those in config/application.rb.
Rails.application.configure do
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Do we care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  config.assets.digest = false
  config.assets.unknown_asset_fallback = false

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  smtp_settings = {
    address: "smtp.sendgrid.net",
    port: "587",
    domain: "#{Settings.app_url}",
    user_name: Rails.application.secrets['sendgrid']['username'],
    password: Rails.application.secrets['sendgrid']['password'],
    authentication: :plain,
    enable_starttls_auto: false
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = smtp_settings

  config.action_mailer.default_url_options = {
    host: "#{Settings.app_url.split('//').last}",
    protocol: "http://"
  }

  if Settings.vcr.enabled
    file = "#{Rails.root}/#{Settings.vcr.library_dir}/#{Settings.vcr.cassette}.yml"
    raise "VCR cassette is too large! Max cassette size is #{Settings.vcr.max_cassette_size}Mb. Check the file size in #{Settings.vcr.library_dir}." if (File.size(file).to_f / 1024000) > Settings.vcr.max_cassette_size
  end
  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
