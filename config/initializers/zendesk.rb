require 'zendesk_api'

class ZendeskClient < ZendeskAPI::Client
  def self.instance
    @instance ||= new do |config|
      # Mandatory:
      config.url = Settings.zendesk.api_url
      # Basic / Token Authentication
      config.username = Rails.application.credentials.dig(:zendesk, :api, :username)
      config.token = Rails.application.credentials.dig(:zendesk, :api, :token)
      config.retry = true
      config.logger = Logger.new(STDOUT)
    end
  end
end
