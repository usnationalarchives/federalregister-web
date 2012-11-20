class CommentsController < ApplicationController
  protect_from_forgery :except => :reload

  with_options(:only => [:new, :reload, :create]) do |during_creation|
    during_creation.layout false
    during_creation.skip_before_filter :authenticate_user!
    during_creation.before_filter :load_entry
    during_creation.before_filter :load_comment_form
    during_creation.before_filter :build_comment
 end

  def index
    @comments = CommentDecorator.decorate(current_user.comments.order('created_at DESC').all)
  end
  
  def new
  end

  def reload
    @comment_reloaded = true

    render :action => :new
  end

  def create
    if user_signed_in?
      @comment.user = current_user
      @comment.comment_publication_notification = true
      @comment.followup_document_notification = true
    end

    if @comment.save
      @comment = CommentDecorator.decorate(@comment)
      render :action => :show, :status => 200
    else
      render :action => :new, :status => 422
    end
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

  def load_entry
    @entry = FederalRegister::Article.find(params[:document_number])
  end

  def load_comment_form
    client = RegulationsDotGov::Client.new(
      SECRETS['regulations_dot_gov']['get_token'],
      SECRETS['regulations_dot_gov']['post_token']
    )
    if @entry.regulations_dot_gov_url
      document_id = @entry.regulations_dot_gov_url.split(/=/).last
      @comment_form = client.get_comment_form(document_id)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def build_comment
    @comment = Comment.new(:comment_form => @comment_form, :document_number => @entry.document_number)
    @comment.attributes = params[:comment] if params[:comment]
    @comment_attachments = @comment.attachments
  end
end
