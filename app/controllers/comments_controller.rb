class CommentsController < ApplicationController
  protect_from_forgery :except => :reload
  skip_before_filter :authenticate_user!, :only => :persist_for_login

  with_options(:only => [:new, :reload, :create]) do |during_creation|
    during_creation.layout false
    during_creation.skip_before_filter :authenticate_user!
    during_creation.before_filter :build_comment
  end

  def index
    @comments = CommentDecorator.decorate(
      current_user.comments.order('created_at DESC').all
    )
  end

  def new
  end

  def reload
    # Check to see if there's any other than the current secret
    # in the comment form store. If not we don't care to show a
    # 'reloaded' message to the viewer when the form is rendered.
    @comment_reloaded = params[:comment].except("secret").present?

    render :action => :new
  end

  def create
    if user_signed_in?
      @comment.user = current_user

      if @comment.agency_participates_on_regulations_dot_gov?
        @comment.comment_publication_notification = true
      end

      @comment.build_subscription(current_user, request)
    end

    @comment.agency_participating = @comment.agency_participates_on_regulations_dot_gov?

    if @comment.save
      @comment.subscription.confirm! if current_user && current_user.confirmed?

      render_created_comment
    else
      render_error_page
    end
  rescue RegulationsDotGov::Client::InvalidSubmission => exception
    begin
      # reload the form from regs.gov
      @comment.load_comment_form(:read_from_cache => false)

      record_regulations_dot_gov_error(
        parse_message(exception.message),
        @comment.document_number
      )

     # try to save with the updated form from the reload above
      if @comment.save
        render_created_comment
      else
        # show invalid form to user with our error messages
        # if say a required field was added after the form was last cached by us
        render_error_page
      end
    rescue RegulationsDotGov::Client::ResponseError => inner_exception
      record_regulations_dot_gov_error(
        parse_message(inner_exception.message),
        @comment.document_number
      )

      # show form to user but with message from regulations.gov
      render_error_page(
        parse_message(inner_exception.message, 'message')
      )
    end
  rescue RegulationsDotGov::Client::ResponseError => exception
    record_regulations_dot_gov_error(
      exception,
      @comment.document_number
    )

    render_error_page(
      "We had trouble communicating with Regulations.gov; try again or visit #{view_context.link_to @comment.article.comment_url, @comment.article.comment_url}"
    )
  end

  def persist_for_login
    %w(comment_tracking_number comment_secret comment_publication_notification followup_document_notification).each do |field|
      session[field] = params[:comment_notifications][field]
    end

    if params[:commit] == "Sign In"
      redirect_to new_session_path
    else
      redirect_to new_user_registration_path
    end
  end

  private

  def render_created_comment
    @comment = CommentDecorator.decorate(@comment)

    CommentMailer.comment_copy(@comment.user, @comment).deliver if user_signed_in?

    render :action => :show, :status => 200
  end

  def render_error_page(error=nil)
    if error
      @comment.errors.add(
        :base,
        error
      )
    end

    render :action => :new, :status => 422
  end

  def build_comment
    @comment = Comment.new
    @comment.document_number = params[:document_number]
    @comment.load_comment_form

    @comment.attributes = params[:comment] if params[:comment]
    @comment = CommentDecorator.decorate( @comment )

    @comment_attachments = @comment.attachments
  end

  def record_regulations_dot_gov_error(exception, document_number)
    Rails.logger.error(exception)

    honeybadger_options = {
      :exception => exception,
      :parameters => {
        :document_number => document_number,
      }
    }
    notify_honeybadger(honeybadger_options)
  end

  # sometimes the message is a json encoded string
  # other times it's just a string
  def parse_message(message, key=nil)
    begin
      if key
        JSON.parse(message)[key]
      else
        JSON.parse(message)
      end
    rescue JSON::ParserError
      message
    end
  end
end
