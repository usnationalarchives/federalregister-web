source 'https://rubygems.org'

gem 'hoe', '~> 3.15', '>= 3.15.2' # TODO: needed for bundler to run in docker but we shouldn't have to specify it explicitely

gem 'rails', '4.2.11'
gem 'rake', '11.3.0'
gem 'rack'


gem 'mysql2', '0.3.21'
# production app server
gem 'passenger', '5.3.6'
gem 'honeybadger'


gem 'federal_register', '0.6.8'
#gem 'federal_register', :path => '../federal_register'
#gem 'federal_register', :git => "https://github.com/usnationalarchives/federal_register.git",
#                        :ref => "master"


gem 'formtastic', '2.3.1'

# model decorators
gem "draper", "~> 1.3.0"

gem 'sass-rails'
gem "sass"
gem 'bootstrap-sass'

gem 'jquery-rails', '~> 3.1.5'
gem 'underscore-rails', '~> 1.6.0'

# file uploads (comment attachments)
gem "carrierwave", "0.11.2"
gem 'fog-aws'

gem "cocaine"
gem "json_builder"

gem "httparty"
gem "httmultiparty"
gem "multi_json"

# api caching
gem 'cachebar', :git => "https://github.com/criticaljuncture/cachebar.git"

gem 'redis', '~> 3.3.5'


gem 'sendgrid'
gem 'active_hash'

gem 'premailer-rails'

# url hyperlinker
gem 'htmlentities'

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

# JSON web tokens (share notifications across services)
gem 'jwt'

# FR Profile client
gem 'faraday'

# CORS support
gem 'rack-cors', require: 'rack/cors'
gem 'rack-cache', "~> 1.6.1"

# background jobs
# resque web interface - rails engine
gem 'resque'
gem 'resque-retry'


# google recaptcha integration
gem 'recaptcha', '0.4.0', require: 'recaptcha/rails'

# Single sign on
gem 'omniauth-openid-connect',
  git: 'https://github.com/criticaljuncture/omniauth-openid-connect',
  branch: 'ruby_1.9.3'

gem 'memoist'

# varnish cache client
gem 'klarlack', '0.0.7',
  git: 'https://github.com/criticaljuncture/klarlack.git',
  ref: 'f4c9706cd542046e7e37a4872b3a272b57cbb31b'

# per-request global storage for Rack.
gem 'request_store'

# add methods to the ruby Process command via C-extensions
# (tracking memory usage)
gem 'proc-wait3'

gem 'coffee-rails', '~> 4.2'
gem 'uglifier'

#ensure connections to missing db don't cause precompilation to fail
gem "activerecord-nulldb-adapter"


group :development, :test do
  gem 'capybara'
  #gem 'capybara-webkit'
  #gem 'capybara-screenshot'

  gem 'codeclimate-test-reporter', :require => nil
  gem 'database_cleaner'
  gem 'email_spec'

  gem "factory_girl_rails", "~> 4.0"
  gem "fakeweb", "~> 1.3.0"

  #auto test runner
  gem 'guard'
  gem 'guard-rspec', require: false

  gem 'launchy'

  gem 'pry'
  gem 'pry-remote'

  # required by current version of draper via its railtie
  # removed in ruby 2.2
  # but not avail in rails 3.2 activesupport
  gem 'test-unit', '~> 3.0'

  gem 'rspec-rails', '~> 3.2'
  gem 'rspec-html-matchers'#, '~> 0.5.0'

  gem 'rubocop', '~> 0.57.0'

  gem 'timecop'

  gem "vcr",     "~> 2.6.0"
  gem 'watchr', '0.7'

  install_if -> { RUBY_PLATFORM =~ /darwin/ } do
    # gem needed for guard on OSX
    gem 'rb-fsevent', require: false

    # OSX notifications
    gem 'terminal-notifier-guard', require: false
  end
end
