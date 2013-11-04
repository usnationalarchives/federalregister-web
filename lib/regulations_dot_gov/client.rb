class RegulationsDotGov::Client
  class APIKeyError < StandardError; end
  class ResponseError < StandardError; end
  class RecordNotFound < ResponseError; end
  class InvalidSubmission < ResponseError; end
  class ServerError < ResponseError; end

  include HTTMultiParty

  cattr_accessor :api_key

  debug_output $stderr
  base_uri 'http://api.data.gov/regulations/v2/'
  default_timeout 20

  DOCKET_PATH = '/docket.json'
  COMMENT_PATH = '/comment.json'

  def self.override_base_uri(uri)
    base_uri(uri)
  end

  def initialize
    raise APIKeyError, "Must provide an api.data.gov API Key" unless self.class.api_key
  end

  def docket_endpoint
    self.class.base_uri + DOCKET_PATH
  end

  def comment_endpoint
    self.class.base_uri + COMMENT_PATH
  end

  def find_docket(docket_id)
    begin
      response = self.class.get(docket_endpoint, :query => {:D => docket_id})
      RegulationsDotGov::Docket.new(self, response.parsed_response)
    rescue ResponseError
    end
  end

  def find_documents(args)
    begin
      response = self.class.get('/documentsearch/v1.json', :query => args.merge(:api_key => @get_api_key))
      results = response.parsed_response['searchresult']
      if results['documents'] && results['documents']['document']
        doc_details = results['documents']['document']
        doc_details = [doc_details] unless doc_details.is_a?(Array)
        doc_details.map{|raw_document| RegulationsDotGov::Document.new(self, raw_document)}
      else
        []
      end

    rescue ResponseError
      []
    end
  end

  def get_comment_form(document_id)
    response = self.class.get(comment_endpoint, :query => {:D => document_id})
    RegulationsDotGov::CommentForm.new(self, response.parsed_response)
  end

  def get_options(field_name, options ={})
    begin
      args = options.merge("lookup" => field_name)
      response = self.class.get('/getlookup/v1.json', :query => args.merge(:api_key => @get_api_key))

      raw_option_attributes = response.parsed_response['lookuplist']['entry']
      if raw_option_attributes.is_a?(Hash)
        raw_option_attributes = [raw_option_attributes]
      end

      raw_option_attributes.map do |option_attributes|
        RegulationsDotGov::CommentForm::Option.new(self, option_attributes)
      end
    end
  end

  def submit_comment(fields)
    response = self.class.post("/submitcomment/v1.json?api_key=#{@post_api_key}", :body => fields)
    response.body.sub(/Comment tracking number: /,'')
  end

  def count_documents(args)
    begin
      response = self.class.get('/documentsearch/v1.json', :query => args.merge(:api_key => @get_api_key, :countsOnly => 1))
      response.parsed_response['searchresult']['recordCount']
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

  def pad_document_number(document_number)
    part_1, part_2 = document_number.split(/-/, 2)
    sprintf("%s-%05d", part_1, part_2.to_i)
  end

  def fetch_by_document_number(document_number)
    response = self.class.get('/getdocument/v1.json', :query => {:api_key => @get_api_key, :FR => document_number})
    RegulationsDotGov::Document.new(self, response.parsed_response["document"])
  end

  def self.get(url, options)
    options[:query].merge!(:api_key => api_key)

    begin
      response = super

      case response.code
      when 200
        response
      when 404
        raise RecordNotFound.new(response)
      when 500
        raise ServerError.new(response.parsed_response['error']['message'])
      else
        raise ResponseError.new(response)
      end
    rescue SocketError
      raise ResponseError.new("Hostname lookup failed")
    rescue Timeout::Error
      raise ResponseError.new("Request timed out")
    end
  end

  def self.post(url, options)
    begin
      response = super

      case response.code
      when 200
        response
      when 412
        raise InvalidSubmission.new(response.parsed_response['error']['message'])
      when 500
        raise ServerError.new(response)
      else
        raise ResponseError.new(response)
      end
    rescue SocketError
      raise ResponseError.new("Hostname lookup failed")
    end
  end

  # force multipart content-type on POST
  def self.hash_contains_files?(hsh)
    true
  end
end
