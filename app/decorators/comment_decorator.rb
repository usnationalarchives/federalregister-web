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
    'the ' + model.agency_name
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

  def tracking_number_link
    if agency_participating
      h.link_to comment_tracking_number, regulations_dot_gov_comment_search_result_url
    else
      h.content_tag(:span,
        comment_tracking_number,
        :class => "tooltip agency-not-participating",
        :"data-tooltip" => 'This agency does not post comments on Regulations.gov. Please contact the agency for further information.',
        :"data-tooltip-class" => 'agency-not-participating'
      )
    end
  end

  def posting_guidelines
    model.posting_guidelines.gsub(
       Regexp.new(
         Comment::AGENCY_POSTING_GUIDELINES_LEXICON.keys.join('|')
       ),
       Comment::AGENCY_POSTING_GUIDELINES_LEXICON
    ).html_safe
  end

  def article
    @article ||= ArticleDecorator.decorate( model.article )
  end
end
