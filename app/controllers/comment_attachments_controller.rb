class CommentAttachmentsController < ApplicationController
  skip_before_filter :authenticate_user!
  protect_from_forgery :except => :create 

  def create
    @comment_attachment = CommentAttachment.new
    @comment_attachment.secret = params[:comment_attachment][:secret]
    @comment_attachment.original_file_name = params[:comment_attachment][:attachment].try(:original_filename)
    @comment_attachment.attachment = params[:comment_attachment][:attachment]

    respond_to do |wants|
      wants.json do
        if @comment_attachment.save
          render :action => "index"
        else
          render :action => "error"
        end
      end
    end
  end

  def destroy
    @comment_attachment = CommentAttachment.find_by_token!(params[:id])
    @comment_attachment.destroy
    render :nothing => true
  end
end
