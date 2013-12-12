ENV["RAILS_ENV"] ||= 'test'

require "rails/application"

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'factory_girl_rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.expect_with :rspec do |c|
    # Disable the `should` syntax...
    c.syntax = :expect
  end
end
