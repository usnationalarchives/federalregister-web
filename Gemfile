source 'https://rubygems.org'

gem 'hoe', '~> 3.15', '>= 3.15.2' # TODO: needed for bundler to run in docker but we shouldn't have to specify it explicitely

gem 'rails', '3.2.22.5'
gem 'rake', '11.3.0'
gem 'rack'


gem 'mysql2', '0.3.18'
# production app server
gem 'passenger', '5.2.0'
gem 'honeybadger'


gem 'federal_register', '0.6.5'
#gem 'federal_register', :path => '../federal_register'
#gem 'federal_register', :git => "https://github.com/usnationalarchives/federal_register.git",
#                        :ref => "master"

gem 'devise', '2.1.2'

gem 'strong_parameters'

gem 'formtastic', '2.0.2'
gem "draper", "~> 1.3.0"

gem 'sass-rails',    "~> 3.2.5"
gem "sass",          "~> 3.2.1"
gem 'bootstrap-sass', '~> 3.0.3.0'

gem 'jquery-rails'
gem 'underscore-rails', '~> 1.6.0'

gem 'userstamp', :git => "https://github.com/delynn/userstamp.git",
                 :ref => "777633"

gem "capistrano", '2.15.4', :require => false
gem "thunder_punch", '0.1.3', :require => false
gem "rvm-capistrano", "~> 1.5.4", :require => false

gem "carrierwave", "0.10.0"
gem "fog", "~> 1.32.0"
gem "pbkdf2"
gem "cocaine"
gem "json_builder"

gem "httparty", "0.14.0"
gem "httmultiparty"
gem "multi_json", "1.12.2"

# api caching
gem 'SystemTimer', :platforms => :ruby_18
gem 'cachebar', :git => "https://github.com/criticaljuncture/cachebar.git"

gem 'redis', '~> 3.3.5'


gem 'sendgrid'
gem 'active_hash'

gem "premailer", "1.8.6"
gem "css_parser", "1.4.5"

# pick item(s) from collection by it's weight/probability
gem "pickup", "0.0.8"

# preview emails in the broswer
gem 'mail_view', :git => 'https://github.com/37signals/mail_view.git'

gem 'indefinite_article'

gem 'geokit', '1.4.1', :require => 'geokit'
gem 'rails_autolink'

gem 'will_paginate', '~> 3.0.7'
gem 'will_paginate-bootstrap', '~> 1.0.1'

gem 'attr_extras', '~> 3.2.0'

# xslt parsing
gem 'nokogiri', '~> 1.6.6'


# make app wide settings easier
gem 'rails_config'

gem 'calendar_helper', :git => "https://github.com/criticaljuncture/calendar_helper.git",
                       :branch => "master"

# parse more date formats when needed
gem 'chronic', '~> 0.10.2'


# set environment variables
gem 'dotenv-rails', '~> 1.0.2'

# background jobs
gem 'resque'
gem 'resque-retry'


# google recaptcha integration
gem 'recaptcha', '0.4.0', require: 'recaptcha/rails'

# Single sign on
gem 'omniauth-openid-connect'

gem 'memoist'

# varnish cache client
gem 'klarlack', '0.0.7',
  git: 'https://github.com/criticaljuncture/klarlack.git',
  ref: 'f4c9706cd542046e7e37a4872b3a272b57cbb31b'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier'

  #ensure connections to missing db don't cause precompilation to fail
  gem "activerecord-nulldb-adapter"
end


group :development, :test do
  gem 'stylin', '~> 0.1.0'
  gem 'rubocop'

  gem 'rspec-rails',                    '>= 2.5'
  gem 'watchr',                         '0.7'
  gem "factory_girl_rails",             "~> 4.0",      :require => false if RUBY_VERSION == '1.9.3'
  gem 'shoulda-matchers',               '1.0.0.beta3'

  if RUBY_VERSION == '1.9.3'
    gem 'zeus'
    gem 'capybara'
    #gem 'capybara-webkit'
    #gem 'capybara-screenshot'
  end

  gem 'database_cleaner'

  gem 'launchy'

  gem 'codeclimate-test-reporter', :require => nil
  gem 'pry'
  #gem 'pry-debugger', :platforms => :ruby_19
  gem 'pry-remote', :platforms => :ruby_19

  #gem 'jasmine-rails', '~> 0.4.7'
  # jasmine dependencies - pre ruby1.9.3
  #gem 'selenium-webdriver',             '2.35.0'
  #gem 'rubyzip',                        '0.9.9'

  gem 'email_spec'

  gem "vcr",     "~> 2.6.0"
  gem "fakeweb", "~> 1.3.0"

  gem 'rspec-html-matchers', '~> 0.5.0'

  gem 'guard'
  #auto test runner
  gem 'guard-rspec', require: false
  # gem needed for guard on OSX
  gem 'rb-fsevent', require: false
  # OSX notifications
  gem 'terminal-notifier-guard', require: false
end
