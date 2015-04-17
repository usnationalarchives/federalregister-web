class TableOfContentsRegularFilingsPresenter < TableOfContentsPresenter

  def initialize(date)
    super
  end

  def url
    base_uri = Rails.env.development? ? Settings.federal_register.base_uri : 'https://www.federalregister.gov'
    "#{base_uri}data/public_inspection_issues/json/#{date.strftime('%Y/%m/%d')}/regular_filing.json"
  end

  def documents
    @regular_filings_data ||= FederalRegister::PublicInspectionDocument.search(query_conditions_regular_filings.
      merge(per_page: 1000,
            fields: ['pdf_url','document_number','html_url','filed_at','docket_numbers','publication_date']
      )
    )
  end

  def document_partial
    'public_inspection_document_issues/document_details.html.erb'
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