module DocumentDecorator::Officialness
  def official?
    publication_date >= Settings.app.officialness.start_date
  end

  def document?
    model.class.to_s == "Document"
  end

  # FR BOX RENDERING
  def fr_content_box_type
    if document?
      official? ? :official_document : :published_document
    else
      :public_inspection_document
    end
  end

  def fr_details_box_type
    if document?
      official? ? :official_document_details : :published_document_details
    else
      :public_inspection_document_details
    end
  end

  def fr_content_box_options
    options = {title: "Published Document: #{document_number} (#{citation})"}
    unless pdf_available?
      options.merge!(
        description: I18n.t('fr_box.description.published_document_no_pdf')
      )
    end
    options
  end
end
