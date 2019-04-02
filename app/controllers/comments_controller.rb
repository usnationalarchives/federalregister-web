class CommentsController < ApplicationController
  protect_from_forgery :except => :reload
  skip_before_filter :authenticate_user!, :only => :persist_for_login

  with_options(:only => [:new, :reload, :create]) do |during_creation|
    during_creation.layout false
    during_creation.skip_before_filter :authenticate_user!
    during_creation.before_filter :build_comment
  end

  before_filter :refresh_current_user, only: :index

  def index
    @comments = CommentDecorator.decorate_collection(
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

    render action: :new
  end

  def create
    if @comment.valid?
      response = @service.send_to_regulations_dot_gov

      if response.status < 400
        @comment.response = response
        @comment.comment_tracking_number = response.tracking_number
        @comment.agency_participating = @comment.agency_participates_on_regulations_dot_gov?

        if user_signed_in?
          @comment.user_id = current_user.id

          if @comment.agency_participates_on_regulations_dot_gov?
            @comment.comment_publication_notification = true
          end

          @comment.build_subscription(current_user, request)
        end
        @comment.save

        track_ipaddress "comment_post_success", request.remote_ip
        render_created_comment
      else
        track_ipaddress "comment_post_failure", request.remote_ip
        render_error_page(response.status)
      end
    else
      render action: :new, status: 400
    end
  end

  def persist_for_login
    %w(comment_tracking_number comment_secret comment_publication_notification followup_document_notification submission_key).each do |field|
      session[field] = params[:comment_notifications][field]
    end

    redirect_to sign_in_url
  end

  private

  def render_created_comment
    @comment.add_submission_key if @comment.comment_tracking_number.nil? && @comment.submission_key.nil?
    @comment = CommentDecorator.decorate(@comment)

    begin
      CommentMailer.comment_copy(@comment.user, @comment).deliver if user_signed_in?
    rescue => exception
      Rails.logger.error(exception)
      notify_honeybadger(exception)
    end

    render action: :show, status: 200
  end


  def render_error_page(status=422)
    render action: :new, status: status
  end

  def build_comment
    @service = RegulationsDotGovCommentService.new(request.remote_ip, params)
    @comment = CommentDecorator.decorate(@service.comment)
    @service.build_comment

    @comment_attachments = @comment.attachments
  rescue RegulationsDotGov::Client::ResponseError, RegulationsDotGov::Client::CommentPeriodClosed, RegulationsDotGov::Client::ServerError => exception
    record_regulations_dot_gov_error( exception )

    response.headers['Regulations-Dot-Gov-Problem'] = "1"

    render json: json_for_regulations_dot_gov_errors(exception),
      status: exception.code && exception.code < 500 ? exception.code : 500
  rescue RegulationsDotGovCommentService::MissingCommentUrl => exception
    response.headers['Comments-No-Longer-Accepted'] = "1"

    render json: {
      modalTitle: t("federal_register_dot_gov_errors.comments_no_longer_accepted.modal_title"),
      modalHtml: t("federal_register_dot_gov_errors.comments_no_longer_accepted.modal_html")
    }
  end

  def record_regulations_dot_gov_error(exception)
    Rails.logger.error(exception)
    notify_honeybadger(exception)
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
        :regulations_dot_gov_link => view_context.link_to(@comment.document.comment_url, @comment.document.comment_url)
      )
    }
  end

  def track_ipaddress(key, ipaddress)
    $redis.zincrby "#{key}:#{Date.current.to_s(:iso)}", 1, ipaddress
  end
end
