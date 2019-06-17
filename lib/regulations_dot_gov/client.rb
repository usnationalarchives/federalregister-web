class RegulationsDotGov::Client
  class APIKeyError < StandardError; end
  class ResponseError < StandardError
    attr_accessor :code
    alias_method :status, :code

    def initialize(message, code=nil)
      super(message)
      @code = code
    end
  end
  class RecordNotFound < ResponseError; end
  class InvalidSubmission < ResponseError; end
  class CommentPeriodClosed < ResponseError; end
  class ServerError < ResponseError; end
  class OverRateLimit < ResponseError; end
  class NonParticipatingAgeny < ResponseError; end

  include HTTParty

  attr_accessor :cache_backups_enabled, :read_from_cache

  if Settings.regulations_dot_gov.debug_output_enabled
    debug_output $stderr
  end

  base_uri(Settings.regulations_dot_gov.base_uri)

  caches_api_responses :key_name => "regulations_dot_gov",
    :expire_in => 1.hour

  HTTParty::HTTPCache.backups_enabled = false

  default_timeout 20

  DOCKET_PATH  = '/docket.json'
  COMMENT_PATH = '/comment.json'
  LOOKUP_PATH  = '/lookup.json'
  DOCUMENT_PATH = '/document.json'
  DOCUMENT_SEARCH_PATH  = '/documents.json'

  def self.override_base_uri(uri)
    base_uri(uri)
  end

  def initialize(options={})
    raise APIKeyError, "Must provide an api.data.gov API Key" unless self.class.api_key.present?
  end

  def self.api_key
    RequestStore.store[:api_key] || Rails.application.secrets[:data_dot_gov][:api_key]
  end

  def self.api_key=(api_key)
    RequestStore.store[:api_key] = api_key
  end

  def docket_endpoint
    self.class.base_uri + DOCKET_PATH
  end

  def comment_endpoint
    self.class.base_uri + COMMENT_PATH
  end

  def lookup_endpoint
    self.class.base_uri + LOOKUP_PATH
  end

  def document_endpoint
    self.class.base_uri + DOCUMENT_PATH
  end

  def document_search_endpoint
    self.class.base_uri + DOCUMENT_SEARCH_PATH
  end

  def find_docket(docket_id)
    response = self.class.get(docket_endpoint, :query => {:docketId => docket_id})
    RegulationsDotGov::Docket.new(self, response.parsed_response)
  end

  def find_documents(args)
    begin
      response = self.class.get(document_search_endpoint, :query => args)

      results = unwrap_response(response)['documents']
      if results.present?
        results.map{|raw_document| RegulationsDotGov::SearchDocument.new(self, raw_document)}
      else
        []
      end

    rescue ResponseError
      []
    end
  end

  def get_comment_form(regulations_dot_gov_document_id)
    # TODO: remove
    # legacy - we used to use document_number and had to deal with
    # adding leading zeros if document number wasn't found.
    fetch_comment_form(regulations_dot_gov_document_id)
  end

  def get_option_elements(field_name, options={})
    begin
      args = options.merge(:field => field_name)
      response = self.class.get(lookup_endpoint, :query => args)

      response = unwrap_response(response)
      raw_option_attributes = response['list']

      raw_option_attributes.map do |option_attributes|
        RegulationsDotGov::CommentForm::Option.new(self, option_attributes)
      end
    end
  end

  def submit_comment(fields)
    response = self.class.post(comment_endpoint, :body => fields, multipart: true)
    RegulationsDotGov::CommentFormResponse.new(self, response)
  end

  def count_documents(args)
    begin
      response = self.class.get(document_search_endpoint, :query => args.merge(:countsOnly => 1))
      response.parsed_response['totalNumRecords']
    rescue ResponseError
      nil
    end
  end

  def find_by_document_number(document_number)
    begin
      begin
        fetch_by_document_number(document_number)
      rescue RecordNotFound, ServerError => e
        revised_document_number = pad_document_number(document_number)
        if revised_document_number != document_number
          fetch_by_document_number(revised_document_number)
        else
          nil
        end
      end
    rescue ResponseError
      nil
    end
  end

  private

  def unwrap_response(response)
    self.class.unwrap_response( response )
  end

  def self.unwrap_response(response)
    response.respond_to?(:parsed_response) ? response.parsed_response : response
  end

  def self.stringify_response(response)
    unwrap_response(response).to_json
  end

  def pad_document_number(document_number)
    part_1, part_2 = document_number.split(/-/, 2)
    sprintf("%s-%05d", part_1, part_2.to_i)
  end

  def fetch_by_document_number(document_number)
    response = self.class.get(document_endpoint, :query => {:federalRegisterNumber => document_number})
    RegulationsDotGov::Document.new(self, response.parsed_response)
  end

  def fetch_comment_form(regulations_dot_gov_document_id)
    response = self.class.get(comment_endpoint, :query => {:D => regulations_dot_gov_document_id})
    response = unwrap_response(response)

    comment_form = RegulationsDotGov::CommentForm.new(self, response)
  end

  def self.get(url, options)
    options[:query].merge!(:api_key => api_key)
    options[:headers] = {"Accept" => "application/json; charset=UTF-8"}

    begin
      response = super

      case response.code
      when 200
        response
      when 0
        JSON.parse(response)
      when 400
        if response['openForComment'] == false
          raise CommentPeriodClosed.new(stringify_response(response), 409)
        elsif response['message'] =~ /does not participate/
          raise NonParticipatingAgeny.new(stringify_response(response), response.code)
        else
          raise ResponseError.new(stringify_response(response), response.code)
        end
      when 404
        raise RecordNotFound.new(stringify_response(response), response.code)
      when 429
        raise OverRateLimit.new( stringify_response(response), response.code)
      when 500, 502, 503
        raise ServerError.new( stringify_response(response), response.code)
      else
        raise ResponseError.new( stringify_response(response), response.code)
      end
    rescue SocketError
      raise ResponseError.new("Hostname lookup failed", 504)
    rescue Timeout::Error
      raise ResponseError.new("Request timed out", 504)
    end
  end

  def self.post(url, options)
    url = url + "?api_key=#{api_key}"

    begin
      response = super

      case response.code
      when 200, 201
        response
      when 400, 406
        raise InvalidSubmission.new( stringify_response(response), response.code)
      when 429
        message = "We were unable to successfully submit your comment at this time because Regulations.gov has received too many comments in the last hour. Please try submitting your comment again later or attempt to comment directly via Regulations.gov, or via any other method described in the document."
        raise OverRateLimit.new(message, response.code)
      when 500, 502, 503
        raise ServerError.new( stringify_response(response), response.code)
      else
        raise ResponseError.new( stringify_response(response), response.code)
      end
    rescue SocketError
      raise ResponseError.new("Hostname lookup failed", 504)
    rescue Timeout::Error
      raise ResponseError.new("Request timed out", 504)
    end
  end
end
