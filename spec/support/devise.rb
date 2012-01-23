RSpec.configure do |config|
  # devise utility method helpers
  config.include Devise::TestHelpers, :type => :controller
  # devise login helpers
  config.extend ControllerMacros, :type => :controller
end
