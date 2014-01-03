source 'http://rubygems.org'

gem 'rails', '3.2.16'
gem 'rake',  '0.9.2.2'

gem 'mysql2', '0.3.11'
gem 'honeybadger'

#gem 'federal_register', '0.5.0'
#gem 'federal_register', :path => '../federal_register'
gem 'federal_register', :git => "git://github.com/criticaljuncture/federal_register.git", 
                        :ref => "7500e781ef3b0c68e507512bd3024c30f7c15aea"

gem 'devise', '2.1.2'
gem 'omniauth', '1.0.1'
gem 'omniauth-facebook', '1.0.0'
gem 'omniauth-twitter', '0.0.7'

gem 'strong_parameters'

gem 'formtastic', '2.0.2'
gem 'draper',     '0.18.0'

gem 'sass-rails',    "~> 3.2.5"
gem "sass",          "~> 3.2.1"
gem 'compass',       '0.12.2'
gem 'compass-rails', "1.0.3"
gem 'oily_png',   "1.0.2"  # C binding for the pure ruby chunky_png used by compass

gem 'jquery-rails'

gem 'userstamp', :git => "git://github.com/delynn/userstamp.git",
                 :ref => "777633"

gem "capistrano", '2.5.19', :require => false
gem "thunder_punch", '0.0.14', :require => false

gem "carrierwave", "0.6.2"
gem "fog", "~> 1.3.1"
gem "pbkdf2"
gem "cocaine"
gem "json_builder"

gem "httparty", "~> 0.12.0"
gem "httmultiparty"

gem 'sendgrid'

gem "premailer", "1.7.3"
gem "css_parser", "1.2.6"

# pick item(s) from collection by it's weight/probability
gem "pickup", "0.0.8"

# preview emails in the broswer
gem 'mail_view', :git => 'https://github.com/37signals/mail_view.git'

gem 'indefinite_article'

# Gems used only for assets and not required
# in production environments by default.
group :assets do 
  gem 'sass-rails',    "~> 3.2.5"
  gem "sass",          "~> 3.2.1"
  gem 'compass',       '0.12.2'
  gem 'compass-rails', "1.0.3"
  gem 'oily_png',   "1.0.2"  # C binding for the pure ruby chunky_png used by compass

  gem 'uglifier'
end

# group :staging do
#   gem 'therubyracer'
# end

group :development do
end

group :development, :test do 
  gem 'rspec-rails',                    '>= 2.5'
  gem 'watchr',                         '0.7'
  gem "factory_girl_rails",             "~> 4.0",      :require => false
  gem 'shoulda-matchers',               '1.0.0.beta3'

  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'

  gem 'database_cleaner'

  gem 'launchy'

  gem 'codeclimate-test-reporter', :require => nil
  gem 'pry'

  #gem 'jasmine-rails', '~> 0.4.7'
  # jasmine dependencies - pre ruby1.9.3
  #gem 'selenium-webdriver',             '2.35.0'
  #gem 'rubyzip',                        '0.9.9'

  gem "vcr",     "~> 2.6.0"
  gem "fakeweb", "~> 1.3.0"
end
