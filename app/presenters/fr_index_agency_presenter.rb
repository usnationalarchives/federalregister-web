class FrIndexAgencyPresenter
  attr_reader :year, :agency_slug, :document_index

  def initialize(year, agency_slug)
    @year = year.to_i
    @agency_slug = agency_slug
    @document_index = HTTParty.get(url)
  end

  def url
    "#{Settings.federal_register.base_uri}/index/#{year}/#{agency_slug}.json"
  end

  def document_partial
    'indexes/doc_details'
  end

  def agency
    @agency ||= {agency_slug => Agency.new(document_index, self) }
  end

  def documents
    @documents ||= Document.search(
      {
        conditions: {
          publication_date: {
            gte: Date.new(year,1,1).to_s(:iso),
            lte: Date.new(year,12,31).to_s(:iso)
          },
          agencies: agency_slug
        },
        per_page: 1000, #TODO: This could present an issue for longer time periods.
        fields: [
          :document_number,
          :end_page,
          :html_url,
          :publication_date,
          :pdf_url,
          :start_page,
        ]
      }
    ).results.map{|d| DocumentDecorator.decorate(d)}
  end

  class Agency < TableOfContentsPresenter::Agency #TODO: Move TableOfContentsPresenter::Agency into top level class

end
