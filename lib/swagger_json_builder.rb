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
    Array.new([{"url": Settings.federal_register.api_url}]).tap do |array|
      if Rails.env.staging? || Rails.env.development?
        all_servers.each {|server| array << server}
      end
    end.uniq
  end

  def all_servers
    [
      {"url": "http://localhost:4002/api/v1/"},
      {"url": "http://fr2.criticaljuncture.org/api/v1/"},
      {"url": "http://www.federalregister.gov/api/v1/"},
    ]
  end

  def host
    if request.ssl?
      request.host
    else
      "#{request.host}:#{request.port}"
    end
  end

  def backends
    Fr::Client.services.map do |slug, client|
      Backend.new(slug, client)
    end.select(&:valid?)
  end
  memoize :backends

  class Backend
    attr_reader :slug, :client
    def initialize(slug, client)
      @slug = slug
      @client = client
    end

    def valid?
      response
      true
    rescue Ecfr::Client::RecordNotFound
      false
    end

    def tag
      {
        "name": slug,
        "description": response["description"]
      }
    end

    def paths
      response["paths"].keys.each do |path|
        verbs = response["paths"].delete(path)
        response["paths"]["/api/#{slug}#{path}"] = verbs.each do |verb, details|
          details["tags"] = [slug]
        end
      end

      response["paths"]
    end

    def response
      @response ||= JSON.parse(client.get("/api/#{slug}/documentation.json").try(:body))
    end
  end

end
