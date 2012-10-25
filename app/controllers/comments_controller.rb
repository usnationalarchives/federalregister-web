class CommentsController < ApplicationController
  layout false
  skip_before_filter :authenticate_user!
  protect_from_forgery :except => :reload

  before_filter :load_entry
  before_filter :load_comment_form
  before_filter :build_comment

  def new
  end

  def reload
    @comment_reloaded = true

    render :action => :new
  end

  def create
    if @comment.save
      @comment = CommentDecorator.decorate(@comment)
      render :action => :show, :status => 200
    else
      render :action => :new, :status => 422
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
      document_id = 'FDA_FRDOC_0001-3317' || @entry.regulations_dot_gov_url.split(/=/).last
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
