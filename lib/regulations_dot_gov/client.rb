class RegulationsDotGov::Client
  class ResponseError < HTTParty::ResponseError; end
  class RecordNotFound < ResponseError; end
  class ServerError < ResponseError; end

  include HTTParty
  base_uri 'http://www.regulations.gov/api/'
  default_timeout 2

  def initialize(get_api_key)
    @get_api_key = get_api_key
  end

  def find_docket(docket_id)
    begin
      response = self.class.get('/getdocket/v1.json', :query => {:api_key => @get_api_key, :D => docket_id}) 
      RegulationsDotGov::Docket.new(self, response.parsed_response["docket"])
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

  def get_comment_form(docket_id)
    begin
      args = {"D" => docket_id}
      response = self.class.get('/getcommentform/v1.json', :query => args.merge(:api_key => @get_api_key))
      RegulationsDotGov::CommentForm.new(self, response.parsed_response['commentFormConfig'])
    rescue ResponseError
      nil
    end
  end

  def get_options(field_name, options ={})
    begin
      args = options.merge("lookup" => field_name)
      response = self.class.get('/getlookup/v1.json', :query => args.merge(:api_key => @get_api_key))
      response.parsed_response['lookuplist']['entry'].map do |option_attributes|
        RegulationsDotGov::CommentForm::Option.new(self, option_attributes)
      end
    end
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
    begin
      response = super

      case response.code
      when 200
        response
      when 404
        raise RecordNotFound.new(response)
      when 500
        raise ServerError.new(response)
      else
        raise ResponseError.new(response)
      end
    rescue SocketError
      raise ResponseError.new("Hostname lookup failed")
    rescue Timeout::Error
      raise ResponseError.new("Request timed out")
    end
  end
end
