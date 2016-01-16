class TableOfContentsSpecialFilingsPresenter < TableOfContentsPresenter
  def initialize(date)
    super(date)
  end

  def url
    "#{Settings.federal_register.base_uri}/public_inspection_issues/json/#{date.strftime('%Y/%m/%d')}/special_filing.json"
  end

  def document_partial
    'public_inspection_document_issues/document_details'
  end

  def documents
    @special_filings_data ||= PublicInspectionDocument.search(
      query_conditions.deep_merge(
        per_page: 1000,
        fields: [
          'docket_numbers',
          'document_number',
          'filed_at',
          'html_url',
          'num_pages',
          'pdf_file_size',
          'pdf_url',
          'publication_date',
        ]
      )
    ).map{|d| PublicInspectionDocumentDecorator.decorate(d)}
  end

  private

  def query_conditions
    if date == PublicInspectionDocumentIssue.current.publication_date
      QueryConditions::PublicInspectionDocumentConditions.special_filing
    else
      QueryConditions::PublicInspectionDocumentConditions.
        special_filings_available_on(date)
    end
  end
end
