class SwaggerJsonBuilder
  extend Memoist
  attr_reader :request

  def initialize(request)
    @request = request
  end

  def as_json
    api_core_open_api_v3 = JSON.parse(Fr::ApiCoreService.get('documentation').body)

    {
      "openapi": "3.0.0",
      "info": {
        "title": "FR API Documentation",
        "version": "1"
      },
      "servers": servers,
      "paths": api_core_open_api_v3['paths'],
      "components": api_core_open_api_v3['components']
    }
  end


  private

  def servers
    Array.new([{"url": "#{Settings.app_url}/api/v1/"}]).tap do |array|
      if Rails.env.staging? || Rails.env.development?
        all_servers.each {|server| array << server}
      end
    end.uniq
  end

  def all_servers
    [
      {"url": "https://fr2.criticaljuncture.org/api/v1/"},
      {"url": "https://www.federalregister.gov/api/v1/"},
    ]
  end

end
