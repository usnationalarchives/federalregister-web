Honeybadger.configure do |config|
  config.api_key = Rails.application.credentials.dig(:honeybadger, :api_key)
end
