module DocumentDecorator::PresidentialDoc

  def pdf_link
    if !historical_eo?
      h.link_to pdf_url do
        "#{h.fr_icon('doc-pdf')} PDF".html_safe
      end
    elsif citation
      h.link_to '#', class: 'fr-archives-pdf-links-modal-js', data: {
          'archives-volume-js' => citation.match(/(\d+) FR/)[1],
          'archives-page-js'   => citation.match(/FR (\d+)/)[1],
          'eo-number'          => executive_order_number
        } do
        "#{h.fr_icon('doc-pdf')} PDF".html_safe
      end
    end
  end

  def presidential_doc_show_link(presenter)
    if (presenter.type == 'executive_orders') && historical_eo?
      h.link_to_if !not_received_for_publication,
        title,
        h.executive_order_path(executive_order_number)
    else
      h.link_to title, h.document_path(self)
    end
  end

  def historical_eo?
    document_number.blank?
  end

  def document_specific_note
    if proclamation_number == '9494'
      note
    end
  end

  def signing_date
    object.signing_date&.to_s(:month_day_year)
  end

  def citation
    if not_received_for_publication
      nil #no-op
    else
      object.citation
    end
  end

  def publication_date_link
    if not_received_for_publication
      "Not received for publication"
    else
      h.link_to_if document_number,
        publication_date&.to_s(:month_day_year),
        h.document_issue_path(self)
    end
  end

end
