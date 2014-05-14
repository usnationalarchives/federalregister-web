class CommentDecorator < ApplicationDecorator
  decorates :comment

  delegate :agency_participates_on_regulations_dot_gov?,
    :to => :comment_form

  def human_error_messages
    if errors.present?
      "There #{errors.count > 1 ? 'were' : 'was'}
       #{h.pluralize(errors.count, 'problem')} with your submission.
       Please fix #{errors.count > 1 ? 'them' : 'it'} below and re-submit your comment."
    end
  end

  def agency_name
    'the ' #+ model.agency_name
  end

  def commented_at
    if comment.created_at
      comment.created_at
    end
  end

  def comment_published_at
    if comment.comment_published_at
      comment.comment_published_at
    else
      "Not posted by agency as of #{Date.today}"
    end
  end

  def regulations_dot_gov_comment_search_result_url
    "http://www.regulations.gov/#!searchResults;rpp=25;po=0;s=#{comment_tracking_number}"
  end
end
