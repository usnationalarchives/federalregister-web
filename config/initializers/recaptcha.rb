Recaptcha.configure do |config|
  config.public_key  = SECRETS['recaptcha']['public']
  config.private_key = SECRETS['recaptcha']['private']

  config.api_version = 'v2'
  config.use_ssl_by_default = true
end
