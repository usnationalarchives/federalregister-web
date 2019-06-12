class CommentPublicationNotificationsController < ApplicationController
  before_action :find_comment
  
  def create
    @comment.comment_publication_notification = true
    @comment.save(validate: false)

    respond_to do |format|
      format.json { render :json => { :link_text => t('notifications.links.remove'),
                                      :method => 'delete',
                                      :description => t('notifications.comment.publication.active')} }
    end
  end

  def destroy
    @comment.comment_publication_notification = false
    @comment.save(validate: false)

    respond_to do |format|
      format.json { render :json => { :link_text => t('notifications.links.add'),
                                      :method => 'post',
                                      :description => t('notifications.comment.publication.inactive')} }
    end
  end

  private

  def find_comment
    @comment = current_user.comments.where(
      comment_tracking_number: params[:comment_tracking_number]
    ).first
  end
end
