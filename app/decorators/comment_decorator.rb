class CommentDecorator < ApplicationDecorator
  decorates :comment
  delegate_all
  delegate :agency_participates_on_regulations_dot_gov?,
    :to => :comment_form

  def regulations_dot_gov_base_url
    if Rails.env.production?
      "http://www.regulations.gov"
    else
      "http://regstest.erulemaking.net"
    end
  end

  def human_error_messages
    if errors.present?
      "There #{errors.count > 1 ? 'were' : 'was'}
       #{h.pluralize(errors.count, 'problem')} with your submission.
       Please fix #{errors.count > 1 ? 'them' : 'it'} below and re-submit your comment."
    end
  end

  def agency_name(capitalized=false)
    the = capitalized ? 'The ' : 'the '

    the + model.agency_name
  end

  def commented_at
    if comment
      comment.created_at
    end
  end

  def comment_posted
    if comment.comment_document_number
      "Publically posted - #{h.link_to comment.comment_document_number, posted_comment_url}".html_safe
    else
      "Not posted by agency as of #{Date.today}"
    end
  end

  def regulations_dot_gov_comment_search_result_url
    "#{regulations_dot_gov_base_url}/#!searchResults;rpp=25;po=0;s=#{comment_tracking_number}"
  end

  def posted_comment_url
    if comment_document_number
      "#{regulations_dot_gov_base_url}/#!documentDetail;D=#{comment_document_number}"
    else
      ""
    end
  end

  def tracking_number_link
    if agency_participating
      h.link_to comment_tracking_number, regulations_dot_gov_comment_search_result_url
    else
      h.content_tag(:span,
        comment_tracking_number,
        :class => "tooltip agency-not-participating",
        :"data-tooltip" => 'This agency does not post comments on Regulations.gov. Please contact the agency for further information.',
        :"data-tooltip-gravity" => 'e',
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

  def comment_count
    document.comment_count
  end

  def comment_count_tooltip
    if comment_count == 0
      h.t('comments.comment_count.none')
    else
      h.t('comments.comment_count', :count => comment_count)
    end
  end

  def comment_count_link
    if comment_count > 0
      h.link_to(
        comment_count,
        posted_comment_url,
        :class => "count"
      )
    elsif comment_count == 0
      h.content_tag(:span, comment_count, :class => "count")
    end
  end
end
