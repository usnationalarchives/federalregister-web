class RegulationsDotGovCommentService
  attr_reader :args, :comment
  attr_accessor :comment_form

  class MissingCommentUrl < StandardError; end

  def initialize(args)
    @args = args

    @comment = Comment.new
    @comment.document_number = @args.delete(:document_number)
  end

  def build_comment
    load_comment_form
    assign_attributes_to_comment
  end

  def load_comment_form(api_options={})
    HTTParty::HTTPCache.reading_from_cache(
      api_options.fetch(:read_from_cache) { true }
    ) do
      client = RegulationsDotGov::Client.new
      client.api_key = SECRETS["data_dot_gov"]["primary_comment_api_key"]

      if comment.document.comment_url
        comment.comment_form = client.get_comment_form(comment.regulations_dot_gov_document_id)
      else
        raise MissingCommentUrl
      end
    end
  end

  def assign_attributes_to_comment
    begin
      if args[:comment]
        comment.secret = args[:comment][:secret]

        # replace line endings that cause char count problems
        if args[:comment]["general_comment"].present?
          args[:comment]["general_comment"].gsub!(/\r\n/, "\n")
        end

        comment.attributes = args[:comment]
      end
    rescue => exception
      record_regulations_dot_gov_error(exception)
    end
  end

  private

  def record_regulations_dot_gov_error(exception)
    Rails.logger.error(exception)
    Honeybadger.notify(exception)
  end
end
