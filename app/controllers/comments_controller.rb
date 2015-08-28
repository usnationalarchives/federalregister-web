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
    track_ipaddress "comment_opened", request.remote_ip
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

      track_ipaddress "comment_post_success", request.remote_ip

      render_created_comment
    else
      track_ipaddress "comment_post_failure", request.remote_ip

      render_error_page
    end
  rescue RegulationsDotGov::Client::InvalidSubmission => exception
    begin
      # reload the form from regs.gov
      @comment.load_comment_form(:read_from_cache => false)

      record_regulations_dot_gov_error(exception)

     # try to save with the updated form from the reload above
      if @comment.save
        render_created_comment
      else
        # show invalid form to user with our error messages
        # if say a required field was added after the form was last cached by us
        render_error_page
      end
    rescue RegulationsDotGov::Client::ResponseError => inner_exception
      record_regulations_dot_gov_error(inner_exception)

      # show form to user but with message from regulations.gov
      render_error_page(
        parse_message(inner_exception.message, 'message')
      )
    end
  rescue RegulationsDotGov::Client::ResponseError => exception
    record_regulations_dot_gov_error(exception)

    render_error_page(
      "We had trouble communicating with Regulations.gov; try again or visit #{view_context.link_to @comment.article.comment_url, @comment.article.comment_url}"
    )
  end

  def persist_for_login
    %w(comment_tracking_number comment_secret comment_publication_notification followup_document_notification submission_key).each do |field|
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

    begin
      if params[:comment]
        @comment.secret = params[:comment][:secret]
        @comment.attributes = params[:comment]
      end
    rescue => exception
      record_regulations_dot_gov_error(exception)
    end

    @comment = CommentDecorator.decorate( @comment )
    @comment_attachments = @comment.attachments
  rescue RegulationsDotGov::Client::ResponseError, RegulationsDotGov::Client::CommentPeriodClosed => exception
    record_regulations_dot_gov_error( exception )

    response.headers['Regulations-Dot-Gov-Problem'] = "1"

    render :json => json_for_regulations_dot_gov_errors(exception),
      :status => exception.code || 500

    # we're in a before filter here
    return false
  end

  def record_regulations_dot_gov_error(exception)
    Rails.logger.error(exception)
    notify_honeybadger(exception)
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

  def json_for_regulations_dot_gov_errors(exception)
    if [500, 502, 503].include?(exception.code)
      error = 'service_unavailable'
    elsif exception.code == 409
      error = 'comments_closed'
    else
      error = 'unknown'
    end

    json = {
      :modalTitle => t(
        "regulations_dot_gov_errors.#{error}.modal_title"
      ),
      :modalHtml => t(
        "regulations_dot_gov_errors.#{error}.modal_html",
        :regulations_dot_gov_link => view_context.link_to(@comment.article.comment_url, @comment.article.comment_url)
      )
    }
  end

  def track_ipaddress(key, ipaddress)
    $redis.zincrby "#{key}:#{Date.current.to_s(:iso)}", 1, ipaddress
  end
end
