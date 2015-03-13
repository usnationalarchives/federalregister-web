source 'https://rubygems.org'

gem 'rails', '3.2.18'
gem 'rake',  '0.9.2.2'

gem 'mysql2', '0.3.11'
gem 'honeybadger'

#gem 'federal_register', '0.5.1'
#gem 'federal_register', :path => '../federal_register'
gem 'federal_register', :git => "git://github.com/criticaljuncture/federal_register.git",
                        :ref => "officialness"

gem 'devise', '2.1.2'

gem 'strong_parameters'

gem 'formtastic', '2.0.2'
gem "draper", "~> 1.3.0"

gem 'sass-rails',    "~> 3.2.5"
gem "sass",          "~> 3.2.1"
gem 'bootstrap-sass', '~> 3.0.3.0'

gem 'jquery-rails'
gem 'underscore-rails', '~> 1.6.0'

gem 'userstamp', :git => "git://github.com/delynn/userstamp.git",
                 :ref => "777633"

gem "capistrano", '2.15.4', :require => false
gem "thunder_punch", '0.1.3', :require => false
gem "rvm-capistrano", "~> 1.5.4", :require => false

gem "carrierwave", "0.6.2"
gem "fog", "~> 1.3.1"
gem "pbkdf2"
gem "cocaine"
gem "json_builder"

gem "httparty", "0.11.0"
gem "httmultiparty"

# api caching
gem 'SystemTimer', :platforms => :ruby_18
gem 'cachebar', :git => "git@github.com:criticaljuncture/cachebar.git"
gem 'redis', '~> 3.0.7'
gem 'redis-namespace'

gem 'sendgrid'
gem 'active_hash'

gem "premailer", "1.7.3"
gem "css_parser", "1.2.6"

# pick item(s) from collection by it's weight/probability
gem "pickup", "0.0.8"

# preview emails in the broswer
gem 'mail_view', :git => 'https://github.com/37signals/mail_view.git'

gem 'indefinite_article'

gem 'geokit', '1.4.1', :require => 'geokit'
gem 'rails_autolink'

gem 'will_paginate'

gem 'attr_extras', '~> 3.2.0'

# make app wide settings easier
gem 'rails_config'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.2'
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
  gem 'passenger', '~> 4.0.57'
end

group :development, :test do
  gem 'stylin', '~> 0.1.0'
  gem 'rubocop'

  gem 'rspec-rails',                    '>= 2.5'
  gem 'watchr',                         '0.7'
  gem "factory_girl_rails",             "~> 4.0",      :require => false if RUBY_VERSION == '1.9.3'
  gem 'shoulda-matchers',               '1.0.0.beta3'

  if RUBY_VERSION == '1.9.3'
    gem 'capybara'
    gem 'capybara-webkit'
    gem 'capybara-screenshot'
  end

  gem 'database_cleaner'

  gem 'launchy'

  gem 'codeclimate-test-reporter', :require => nil
  gem 'pry'
  gem 'pry-debugger', :platforms => :ruby_19
  gem 'pry-remote', :platforms => :ruby_19

  #gem 'jasmine-rails', '~> 0.4.7'
  # jasmine dependencies - pre ruby1.9.3
  #gem 'selenium-webdriver',             '2.35.0'
  #gem 'rubyzip',                        '0.9.9'

  gem 'email_spec'

  gem "vcr",     "~> 2.6.0"
  gem "fakeweb", "~> 1.3.0"
end
