Recaptcha.configure do |config|
  config.public_key  = Rails.application.credentials.dig(:recaptcha, :public)
  config.private_key = Rails.application.credentials.dig(:recaptcha, :private)

  config.api_version = 'v2'
  config.use_ssl_by_default = true
end
