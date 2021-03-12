class CommentsController < ApplicationController
  AGENCY_NAMES = YAML::load_file(Rails.root.join('data', 'regulations_dot_gov_agencies.yml'))
  class OldV3SubmissionError < StandardError; end
  protect_from_forgery except: :reload, with: :reset_session
  skip_before_action :authenticate_user!, :only => :persist_for_login

  with_options(:only => [:new, :reload, :create]) do |during_creation|
    during_creation.layout false
    during_creation.skip_before_action :authenticate_user!
  end

  before_action :refresh_current_user, only: :index

  def index
    @comments = CommentDecorator.decorate_collection(
      current_user.comments.order('created_at DESC').all
    )
  end

  def new
    track_ipaddress "comment_opened", request.remote_ip

    head :ok
  end

  def create
    if params['comment'].present?
      # Make sure we proactively 500 if someone is attempting to submit an older version of the comment form during deployment
      raise OldV3SubmissionError
    end

    reg_gov_document_id = params['reg_gov_response_data']['attributes']['commentOnDocumentId']
    reg_gov_agency_name = reg_gov_document_id.try(:split, '-').try(:first)
    reg_gov_agency      = AGENCY_NAMES[reg_gov_agency_name]

    @comment = Comment.new(
      document_number:         params['document_number'],
      comment_tracking_number: params['reg_gov_response_data']['id'],
      agency_name:             reg_gov_agency,
      agency_participating:    reg_gov_agency.present?,
    )

    if user_signed_in?
      @comment.user_id = current_user.id

      #TODO: Confirm whether we can assume that an agency is participating if they're in the YML file?
      if @comment.agency_participating#@comment.agency_participates_on_regulations_dot_gov?
        @comment.comment_publication_notification = true
      end

      @comment.build_subscription(current_user, request)
    end
    @comment.save!

    track_ipaddress "comment_post_success", request.remote_ip
    render_created_comment
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

    render action: :show, status: 200
  end

  def track_ipaddress(key, ipaddress)
    $redis.zincrby "#{key}:#{Date.current.to_s(:iso)}", 1, ipaddress
  end
end
