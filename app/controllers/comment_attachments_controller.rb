class CommentAttachmentsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    @comment_attachment = CommentAttachment.new
    @comment_attachment.secret = params[:comment_attachment][:secret]
    @comment_attachment.original_file_name = params[:comment_attachment][:attachment].try(:original_filename)
    @comment_attachment.attachment = params[:comment_attachment][:attachment]

    respond_to do |wants|
      # IE8 & 9 require the response to come back as text/html and
      # only make the request as html...
      wants.html do
        render :json => jq_upload_response.to_json,
          :content_type => 'text/html',
          :layout => false
      end
      wants.json do
        render :json => jq_upload_response.to_json
      end
    end
  end

  def destroy
    @comment_attachment = CommentAttachment.find_by_token!(params[:id])
    @comment_attachment.destroy
    head :ok
  end

  private

  def jq_upload_response
    if @comment_attachment.save
      {:files => [@comment_attachment.to_jq_upload]}
    else
      {:files => [@comment_attachment.to_jq_upload_error]}
    end
  end
end
