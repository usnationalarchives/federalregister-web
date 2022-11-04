ENV["RAILS_ENV"] = 'test'

require "rails/application"
require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'factory_girl_rails'

#require 'capybara-screenshot/rspec'

require "email_spec"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures  = false
  config.example_status_persistence_file_path = "spec/rspec_example_status_persistence_file.txt"

  config.include FactoryGirl::Syntax::Methods

  config.include Features::SessionHelpers, type: :feature
  config.include Features::ClippingHelpers, type: :feature
  config.include Features::SubscriptionHelpers, type: :feature
  config.include OauthTestHelpers, type: :controller

  config.include Capybara::RSpecMatchers, type: :feature

  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  config.include Rails.application.routes.url_helpers
  config.include RouteBuilder

  config.include Models::ApiHelpers#, type: :model
  config.include Models::SearchHelpers

  config.include RSpecHtmlMatchers

  config.expect_with :rspec do |c|
    # Disable the `should` syntax...
    c.syntax = :expect
  end

  config.before(:suite) do
    # Do truncation once per suite
    DatabaseCleaner.clean_with :truncation

    # Normally do transactions-based cleanup
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |spec|
    if spec.metadata[:js]
      spec.run
      DatabaseCleaner.clean_with :deletion
    else
      DatabaseCleaner.start
      spec.run
      DatabaseCleaner.clean
    end
  end

  config.before(:each, isolate_redis: true) do
    $redis.flushdb
  end
  config.after(:each, isolate_redis: true) do
    $redis.flushdb
  end

  config.before(:each) { reset_mailer }

  Capybara.run_server = true
  Capybara.server_port = 14000 + ENV['TEST_ENV_NUMBER'].to_i
  Capybara.app = Rack::Builder.parse_file(File.expand_path('../../config.ru', __FILE__)).first

  Capybara.asset_host = "http://fr2.dev:#{8081 + ENV['TEST_ENV_NUMBER'].to_i}"
  Capybara.app_host = "http://fr2.dev:#{8081 + ENV['TEST_ENV_NUMBER'].to_i}"
  Capybara.current_driver = :webkit
  Capybara.javascript_driver = :webkit
  Capybara.default_max_wait_time = 5
end
