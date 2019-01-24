Recaptcha.configure do |config|
  config.public_key  = Rails.application.secrets[:recaptcha][:public]
  config.private_key = Rails.application.secrets[:recaptcha][:private]

  config.api_version = 'v2'
  config.use_ssl_by_default = true
end
