ENV["RAILS_ENV"] ||= 'test'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "rails/application"
require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'factory_girl_rails'

require 'capybara-screenshot/rspec'

require "email_spec"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures  = false

  config.include FactoryGirl::Syntax::Methods

  config.include Warden::Test::Helpers, :type => :feature
  Warden.test_mode!

  config.include Features::SessionHelpers, type: :feature
  config.include Features::ClippingHelpers, type: :feature
  config.include Features::SubscriptionHelpers, type: :feature

  config.include Capybara::RSpecMatchers, type: :feature

  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  config.include Rails.application.routes.url_helpers
  config.include RouteBuilder

  config.include Models::ApiHelpers#, type: :model
  config.include Models::SearchHelpers

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

  config.before(:each) { reset_mailer }

  Capybara.run_server = true
  Capybara.server_port = 14000
  Capybara.app = Rack::Builder.parse_file(File.expand_path('../../config.ru', __FILE__)).first

  Capybara.asset_host = "http://www.fr2.dev:8081"
  Capybara.app_host = "http://www.fr2.dev:8081"
  Capybara.current_driver = :webkit
  Capybara.javascript_driver = :webkit
  Capybara.default_wait_time = 5
end
