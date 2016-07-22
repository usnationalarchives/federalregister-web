class TableOfContentsPublicInspectionPresenter < TableOfContentsPresenter
  def url
    "#{Settings.federal_register.base_uri}/public_inspection_issues/json/#{date.strftime('%Y/%m/%d')}/#{url_type}.json"
  end

  def document_partial
    'public_inspection_document_issues/document_details'
  end

  def documents
    retrieve_documents.map{|d| PublicInspectionDocumentDecorator.decorate(d)}
  end

  private

  def retrieve_documents
    @documents ||= PublicInspectionDocument.find_all(
      document_numbers,
      {
        per_page: 1000,
        fields: document_fields
      }
    )
  end

  def document_fields
    [
      :agencies,
      :docket_numbers,
      :document_number,
      :editorial_note,
      :filed_at,
      :filing_type,
      :html_url,
      :num_pages,
      :pdf_file_size,
      :pdf_url,
      :publication_date,
    ]
  end
end
