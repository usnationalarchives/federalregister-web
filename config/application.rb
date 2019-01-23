require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyFr2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/base_extensions #{config.root}/app/presenters #{config.root}/app/services)


    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # Use routes to pickup exceptions - allows us to serve pretty error pages
    config.exceptions_app = self.routes

    config.action_dispatch.rescue_responses.merge!(
      'FederalRegister::Client::RecordNotFound' => :not_found
    )

    unless Rails.env.test?
      # add passenger process id and request uuid to logs
      config.log_tags = [Proc.new { "PID: %.5d" % Process.pid }, :uuid]
    end

    # Configure HTTParty API caching
    HTTParty::HTTPCache.logger = Rails.logger
    HTTParty::HTTPCache.timeout_length = 30 # seconds
    HTTParty::HTTPCache.cache_stale_backup_time = 120 # seconds

    config.active_record.belongs_to_required_by_default = false
  end
end
