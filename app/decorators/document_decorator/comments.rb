module DocumentDecorator::Comments

  def has_comments?
    comment_count && comment_count > 0
  end

  def docket_comment_count
    regulations_dot_gov_info && regulations_dot_gov_info['docket_comments_count']
  end

  def comment_count
    regulations_dot_gov_info && regulations_dot_gov_info['comments_count']
  end

  def accepting_comments?
    document_comment_period_open? || regulations_dot_gov_accepting_comments?
  end

  def document_comment_period_open?
    comments_close_on.present? && comments_close_on >= Time.current.to_date
  end

  # occasionally comment periods are extended on regulations.gov past the
  # originally published date in the document
  def regulations_dot_gov_accepting_comments?
    comment_url.present? && publication_date.to_time > 4.months.ago
  end

  def formal_comment_link
    link_text = "Submit a formal comment"

    if comment_url.present?
      href = comment_url
      options = { target: '_blank', :'data-comment' => 1}
    else
      href = '#addresses'
      options = {}
    end

    h.link_to link_text, href, {id: 'start_comment', class: 'button formal_comment'}.merge(options)
  end

  def comment_link
    link_text = "Submit a public comment on this document"
    href = if comment_url.present?
      if Settings.regulations_dot_gov.use_beta
        "https://beta.regulations.gov/comment/#{regulations_dot_gov_document_id}"
      else
        comment_url
      end
    else
      '#addresses'
    end

    h.link_to link_text, href, id: 'utility-nav-comment-link'
  end

  def comment_period_days_remaining
    if document_comment_period_open?
      num_days = comments_close_on - Time.current.to_date

      if num_days > 0
        "in " + h.pluralize(num_days.to_i, 'day')
      else
        'today'
      end
    end
  end

  def regulations_dot_gov_agency_id
    return '' unless regulations_dot_gov_info && regulations_dot_gov_info['agency_id']

    regulations_dot_gov_info['agency_id']
  end

  def public_comments_url
    return unless has_comments?

    "https://beta.regulations.gov/document/#{regulations_dot_gov_document_id}/comment"
  end
end
