class Fr::Client
  class Error < StandardError
    attr_reader :record
    def initialize(record=nil, message="")
      @record = record
      super(message)
    end
  end

  class BadRequest < Error; end
  class InvalidRequest < Error; end
  class RecordNotFound < Error; end
  class ResponseError < Error; end
  class ServerError < Error; end
  class UnknownStatusCode < Error; end
  class Forbidden < Error; end

  def self.client
    if Settings.log_http_requests
      Faraday.new(url: self::BASE_URL) do |faraday|
        faraday.request :url_encoded
        faraday.use Ecfr::Client::FaradayInstrumentation
        faraday.adapter  Faraday.default_adapter
      end
    else
      Faraday.new(url: self::BASE_URL)
    end
  end

  def self.services
    {
      "api-core" => Fr::ApiCoreService,
    }
  end


  protected

  def self.get(path, options={})
    begin
      handle_response_status(
        client.get(path, options)
      )
    rescue Faraday::Error::ConnectionFailed
      raise ResponseError.new('Hostname lookup failed')
    rescue Faraday::TimeoutError
      raise ResponseError.new('Request timed out')
    end
  end


  def self.handle_response_status(response)
    begin
      errors = JSON.parse(response.body)
    rescue
      errors = nil
    end

    case response.status
    when 200, 201, 204
      response
    when 400
      raise BadRequest, errors
    when 403
      raise Forbidden, errors
    when 404
      raise RecordNotFound
    when 422
      raise InvalidRequest
    when 500
      raise ServerError
    else
      raise UnknownStatusCode, errors, "Status code: #{response.status}"
    end
  end

end
