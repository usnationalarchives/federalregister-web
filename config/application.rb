require File.expand_path('../boot', __FILE__)

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

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Compress JavaScripts and CSS
    config.assets.js_compressor = :uglifier
    config.assets.css_compressor = :sass

    # Don't fallback to assets pipeline if a precompiled asset is missed
    config.assets.compile = false

    # Change path for generated assets
    #config.assets.prefix = "assets"

    # Configure load paths for SASS
    config.sass.load_paths << "#{Rails.root}/vendor/assets/stylesheets/"
    config.sass.load_paths << "#{Rails.root}/app/assets/fonts"

    # Generate digests for assets URLs
    config.assets.digest = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Use routes to pickup exceptions - allows us to serve pretty error pages
    config.exceptions_app = self.routes

    config.action_dispatch.rescue_responses.merge!(
      'FederalRegister::Client::RecordNotFound' => :not_found
    )

    config.assets.paths << "#{Rails.root}/app/assets/fonts"

    unless Rails.env.test?
      # add passenger process id and request uuid to logs
      config.log_tags = [Proc.new { "PID: %.5d" % Process.pid }, :uuid]
    end

    # Configure HTTParty API caching
    HTTParty::HTTPCache.logger = Rails.logger
    HTTParty::HTTPCache.timeout_length = 30 # seconds
    HTTParty::HTTPCache.cache_stale_backup_time = 120 # seconds
  end
end
