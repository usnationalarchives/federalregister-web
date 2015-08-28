class CommentFollowupDocumentNotificationsController < ApplicationController
  before_filter :find_comment

  def create
    @comment.subscription.confirm!

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
      @comment = current_user.comments.first(:conditions => {
        :comment_tracking_number => params[:comment_tracking_number]
      })
    else
      #agency not participating
      @comment = current_user.comments.first(:conditions => {
        :submission_key => params[:submission_key]
      })
    end
  end
end
