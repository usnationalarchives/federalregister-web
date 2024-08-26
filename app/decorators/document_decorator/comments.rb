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

  # This method provides us with a way to know whether the document is
  # open for comment irrespective of whether its publishing agencies receive
  # submissions at regulations.gov.
  # We still want to show a "Submit a comment" link in these cases, but link
  # to text in the FR document itself
  def document_comment_period_open?
    comments_close_on.present? && comments_close_on >= Time.current.to_date
  end

  # this is not the negation of #document_comment_period_open? as it requires
  # there to be a comments_close_on present
  def document_comment_period_closed?
    comments_close_on.present? && comments_close_on < Time.current.to_date
  end

  # occasionally comment periods are extended on regulations.gov past the
  # originally published date in the document
  def regulations_dot_gov_accepting_comments?
    regs_dot_gov_documents_accepting_comments.present?
  end

  # show date if document comment date isn't past or is past and doc is no
  # longer open for comment - we don't want to show the date when the comment
  # period has been extended as this is confusing
  def display_comment_close_date?
    document_comment_period_open? ||
      (document_comment_period_closed? &&
        !regulations_dot_gov_accepting_comments?)
  end

  def formal_comment_link
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
    href = if comment_url.present?
      calculated_comment_url
    else
      '#addresses'
    end

    h.link_to link_text, href, id: 'utility-nav-comment-link', class: 'force-event-propagation'
  end

  def posted_comments_link
    posted_comments_link_text = "View posted comments"

    if more_than_one_regs_dot_gov_document_with_comments?
      h.link_to posted_comments_link_text, "#", class: "deploy-comment-sidebar-js"
    else
      h.link_to posted_comments_link_text, public_comments_url, target: "_blank"
    end
  end

  def more_than_one_regs_dot_gov_document_with_comments?
    regs_dot_gov_documents.select do |x|
      x.comment_count && x.comment_count > 0
    end.count > 1
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

    doc_with_max_comments = regs_dot_gov_documents_accepting_comments.max_by{|x| x.comment_count}
    if doc_with_max_comments
      "https://www.regulations.gov/document/#{doc_with_max_comments.id}/comment"
    else
      nil #ie Not needed if no regs dot gov doc exists
    end
  end

  def regs_dot_gov_documents_once_accepted_comments
    regs_dot_gov_documents.select(&:once_accepted_comments?)
  end

  def regs_dot_gov_documents_accepting_comments
    regs_dot_gov_documents.select(&:accepting_comments?)
  end

  def once_accepted_comments?
    comments_close_on.present? ||
      regs_dot_gov_documents_once_accepted_comments.present?
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

  def link_text
    if comment_url.present?
      "Submit a formal comment"
    else
      "View Commenting Instructions"
    end
  end

  def default_regs_dot_gov_document
    regs_dot_gov_documents_accepting_comments.first
  end

end
