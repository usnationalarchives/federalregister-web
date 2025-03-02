source 'https://rubygems.org'

# basic rails stack
gem 'rails', '~> 6.1.7'
gem 'rake'
gem 'rack'
gem 'mysql2', '0.5.6'
gem 'passenger', '~> 6.0' # production app server
gem 'bootsnap', require: false
gem 'handlebars_assets'


# AR like interface to static data hash based classes
gem 'active_hash'

# json generation
gem "active_model_serializers", "~> 0.10"

#ensure connections to missing db don't cause precompilation to fail
gem "activerecord-nulldb-adapter"

# URI encoding (Ruby 2.7 deprecates URI.encode)
gem 'addressable'

# remove boilerplate code for abstracting small, focused classes
gem 'attr_extras', '~> 3.2.0'

# bootstrap sass integration
gem 'bootstrap-sass'

# html calendar generation
gem 'calendar_helper',
  git: "https://github.com/criticaljuncture/calendar_helper.git",
  branch: 'master'

# link citations & internal references
gem 'reference_parser',
  github: 'criticaljuncture/reference_parser',
  branch: 'main'

# parse more date formats when needed
gem 'chronic', '~> 0.10.2'

# command line integration
gem "cocaine"

# coffeescript integration
gem 'coffee-rails', '~> 5.0'

# app wide settings
gem 'config'

# model decorators
gem "draper"

# http client - FR Profile
gem 'faraday'

# FR API ruby library
# gem 'federal_register', '0.7.7'
#gem 'federal_register', :path => '../federal_register'
gem 'federal_register',
  :git => "https://github.com/usnationalarchives/federal_register.git",
  :branch => "http_client_change"

# aws integration
gem 'fog-aws'

# forms
gem 'formtastic'
gem 'simple_form'

# geocoding and distance calculation API
gem 'geokit', '1.4.1', require: 'geokit'

# url hyperlinker
gem 'htmlentities'

# error reporting
gem 'honeybadger'

# http requests
gem "httparty"

# Used for stimulusjs
gem "importmap-rails"

# adds indefinite article methods to String and Symbol
gem 'indefinite_article'

# structured logging
gem "lograge"
gem "lograge-sql"

# JSON web tokens (share notifications across services)
gem 'jwt'

# jquery integration
gem 'jquery-rails'

# varnish cache client
gem 'klarlack', '0.0.7',
  git: 'https://github.com/criticaljuncture/klarlack.git',
  ref: 'f4c9706cd542046e7e37a4872b3a272b57cbb31b'

# preview emails in the broswer
gem 'mail_view',
  git: 'https://github.com/37signals/mail_view.git'

# enhanced method memoization
gem 'memoist'

# xslt parsing
gem 'nokogiri'

# Allow creation of some non-digested assets
gem "non-digest-assets"

# Single sign on
gem 'omniauth_openid_connect',
  git: 'https://github.com/criticaljuncture/omniauth-openid-connect',
  branch: 'master'

# pick item(s) from collection by it's weight/probability
gem "pickup", "0.0.8"

# inline css for mailer templates
gem 'premailer-rails'

# add methods to the ruby Process command via C-extensions
# (tracking memory usage)
gem 'proc-wait3'

# CORS support
gem 'rack-cors', require: 'rack/cors'

# automatically create links urls, etc. in text
gem 'rails_autolink'

# google recaptcha integration
gem 'recaptcha', '0.4.0', require: 'recaptcha/rails'

# redis integration - background jobs, etc.
gem 'redis'

# per-request global storage for Rack.
gem 'request_store'
gem 'request_store-sidekiq', '~> 0.1'

# explicit add needed to support Ruby 2.7
gem 'rexml'

# sass integration
gem 'sass-rails', '~> 5.1'
gem "sass"

# add safer handling for target="_blank"
gem 'safe_target_blank'

# email provider integration
gem 'sendgrid'

# background jobs
gem 'sidekiq', '~> 6.5.5'
gem "sidekiq-throttled"

# send messages to slack
gem "slack-notifier"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Sprockets 4 ES6 Support
gem "terser"

# search pagination
gem 'will_paginate'
gem 'will_paginate-bootstrap', '~> 1.0.1'

# cron scheduling
gem 'whenever'

gem 'sitemap_generator'

# zendesk-based support tickets
gem 'zendesk_api'

group :development do
  gem 'web-console', '~> 2.0'
  gem "spring"
  gem 'spring-commands-rspec'
end

group :development, :test do
  gem 'capybara'
  #gem 'capybara-webkit'
  #gem 'capybara-screenshot'

  gem 'database_cleaner'
  gem 'email_spec'

  gem "factory_girl_rails", "~> 4.0"
  gem 'webmock'

  #auto test runner
  gem 'guard'
  gem 'guard-rspec', require: false

  gem 'launchy'

  gem 'pry'
  gem 'pry-remote'

  gem 'rspec-rails', '~> 3.2'
  gem 'rspec-html-matchers'#, '~> 0.5.0'

  # parallel rspec
  gem "parallel_tests"
  gem "turbo_tests"

  # rspec results for CI
  gem "rspec_junit_formatter"

  gem 'rubocop', '~> 0.57.0'

  gem 'timecop'

  gem "vcr", "~> 2.6.0"
  gem 'watchr', '0.7'
end

group :test do
  gem 'mock_redis'
end
