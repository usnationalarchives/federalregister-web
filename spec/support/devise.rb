# need to explicitly load this file for CI, for unknown reasons
Rails.root.join("spec/support/controller_macros.rb")

RSpec.configure do |config|
  # devise utility method helpers
  config.include Devise::TestHelpers, :type => :controller
  # devise login helpers
  config.extend ControllerMacros, :type => :controller
end
