class TableOfContentsRegularFilingsPresenter < TableOfContentsPresenter

  def initialize(date)
    super(date)
  end

  def url
    "#{Settings.federal_register.base_uri}/public_inspection_issues/json/#{date.strftime('%Y/%m/%d')}/regular_filing.json"
  end

  def documents
    @regular_filings_data ||= PublicInspectionDocument.search(
      query_conditions_regular_filings.
        merge(
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

  def document_partial
    'public_inspection_document_issues/document_details'
  end

private

  def query_conditions_regular_filings
    {
      conditions: {
        available_on: date.to_date,
        special_filing: 0
      }
    }
  end


end
