class CommentFollowupDocumentNotificationsController < ApplicationController
  before_action :find_comment

  def create
    @comment.subscription.activate!
    
    respond_to do |format|
      format.json { render :json => { :link_text => t('notifications.links.remove'),
                                      :method => 'delete',
                                      :description => t('notifications.comment.followup_document.active')} }
    end
  end

  def destroy
    @comment.subscription.unsubscribe!

    respond_to do |format|
      format.json { render :json => { :link_text => t('notifications.links.add'),
                                      :method => 'post',
                                      :description => t('notifications.comment.followup_document.inactive')} }
    end
  end

  private

  def find_comment
    if params[:comment_tracking_number].present?
      @comment = current_user.comments.where(
        comment_tracking_number: params[:comment_tracking_number]
      ).first
    else
      #agency not participating
      @comment = current_user.comments.where(
        submission_key: params[:submission_key]
      ).first
    end
  end
end
