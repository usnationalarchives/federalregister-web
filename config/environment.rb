# See comment at the top of config/initializers/monkey_patch.rb
if Rails.env == "development"
  ENV['RAILS_RELATIVE_URL_ROOT'] = '/my'
end

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
MyFr2::Application.initialize!
