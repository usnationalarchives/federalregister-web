require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyFr2
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    
    %w(lib).each do |path|
      config.autoload_paths << Rails.root.join(path)
      config.eager_load_paths << Rails.root.join(path)
    end

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

    config.active_record.belongs_to_required_by_default = false
  end
end
