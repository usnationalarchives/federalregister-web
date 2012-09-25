class CommentsController < ApplicationController
  skip_before_filter :authenticate_user!
  protect_from_forgery :except => :create 

  before_filter :load_entry
  before_filter :load_comment_form
  before_filter :build_comment

  def new
  end

  def create
    @comment.attributes = params[:comment]
    @comment_attachments = @comment.attachments

    if @comment.save
      redirect_to root_url#, :flash => "Comment submitted!"
    else
      render :action => :new
    end
  end

  private 

  def load_entry
    @entry = FederalRegister::Article.find(params[:document_number])
  end

  def load_comment_form
    client = RegulationsDotGov::Client.new(SECRETS['regulations_dot_gov']['get_token'])
    @comment_form = client.get_comment_form(@entry.regulations_dot_gov_url.split(/=/).last) 
  end

  def build_comment
    @comment = Comment.new(:comment_form => @comment_form)
  end
end
