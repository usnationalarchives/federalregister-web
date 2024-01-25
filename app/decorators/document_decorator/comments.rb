module DocumentDecorator::Comments

  def has_comments?
    comment_count && comment_count > 0
  end

  def comment_count
    regs_dot_gov_documents.map(&:comment_count).compact.sum
  end

  def republished_document_comment_url
    if republication?
      republished_document = correction_of_document
      if republished_document.document_comment_period_open?
        republished_document.html_url
      end
    end
  end

  def accepting_comments?
    document_comment_period_open? || regulations_dot_gov_accepting_comments?
  end

  def document_comment_period_open?
    # NOTE: This method provides us with a way to know whether the document is open for comment irrespective of whether its publishing agencies receive submissions at regulations.gov.  We still want to show a "Submit a comment" link in these cases, but link to text in the FR document itself
    comments_close_on.present? && comments_close_on >= Time.current.to_date
  end

  # occasionally comment periods are extended on regulations.gov past the
  # originally published date in the document
  def regulations_dot_gov_accepting_comments?
    commentable_documents.present?
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
      calculated_comment_url
    else
      '#addresses'
    end

    h.link_to link_text, href, id: 'utility-nav-comment-link', class: 'force-event-propagation'
  end

  def calculated_comment_url
    if default_regs_dot_gov_document
      "https://www.regulations.gov/commenton/#{default_regs_dot_gov_document.id}"
    else
      nil #ie Not needed if no regs dot gov doc exists
    end
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

  def checked_regulationsdotgov_at
    if regulations_dot_gov_info && regulations_dot_gov_info['checked_regulationsdotgov_at']
      Time.parse(regulations_dot_gov_info['checked_regulationsdotgov_at']).localtime
    end
  end

  def regulations_dot_gov_agency_id
    return '' unless regulations_dot_gov_info && regulations_dot_gov_info['agency_id']

    regulations_dot_gov_info['agency_id']
  end

  def public_comments_url
    return unless has_comments?

    doc_with_max_comments = commentable_documents.max_by{|x| x.comment_count}
    if doc_with_max_comments
      "https://www.regulations.gov/document/#{doc_with_max_comments.id}/comment"
    else
      nil #ie Not needed if no regs dot gov doc exists
    end
  end

  def ever_commentable_documents
    regs_dot_gov_documents.select(&:ever_commentable?)
  end

  def commentable_documents
    regs_dot_gov_documents.select(&:commentable?)
  end

  def dockets_displayed_in_enhanced_content
    dockets.reject(&:default_docket?)
  end

  def dockets
    dockets_attributes = attributes['dockets']
    if dockets_attributes.present?
      dockets_attributes.map do |attrs|
        Docket.new(attrs.stringify_keys)
      end
    else
      []
    end
  end

  def regs_dot_gov_documents
    dockets.flat_map(&:regs_dot_gov_documents)
  end

  private

  def default_regs_dot_gov_document
    commentable_documents.first
  end

end
