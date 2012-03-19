# See comment at the top of config/initializers/monkey_patch.rb
ENV['RAILS_RELATIVE_URL_ROOT'] = '/my'

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
MyFr2::Application.initialize!
