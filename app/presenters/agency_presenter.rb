class AgencyPresenter
  include RouteBuilder::Fr2ApiUrls

  attr_reader :agency

  delegate :agency_url,
    :name,
    :search_conditions,
    :slug,
    :total_document_count,
    :total_public_inspection_document_count,
    :total_significant_document_count,
    :url, to: :@agency

  def initialize(slug)
    @agency = Agency.find(slug)
  end

  def feed_urls
    feeds = []

    feeds << FeedAutoDiscovery.new(
      url: documents_search_api_path(
        {conditions: search_conditions[:conditions]},
        format: :rss
      ),
      description: Search::Document.new(
        conditions: search_conditions[:conditions]
      ).summary,
      search_conditions: search_conditions[:conditions]
    )

    feeds << FeedAutoDiscovery.new(
      url: documents_search_api_path(
        {conditions: search_conditions[:conditions].merge(significant: '1')},
        format: :rss
      ),
      description: Search::Document.new(
        conditions: search_conditions[:conditions].merge(significant: '1')
      ).summary,
      search_conditions: search_conditions[:conditions].merge(significant: '1')
    )

    feeds
  end

  def weekly_sparkline
    SparklinePresenter.new(
      QueryConditions::DocumentConditions.
        published_in_last(1.year).
        deep_merge!(search_conditions),
      period: :weekly,
      title: 'Last year, weekly'
    )
  end

  def monthly_sparkline
    SparklinePresenter.new(
      QueryConditions::DocumentConditions.
        published_in_last(5.years).
        deep_merge!(search_conditions),
      period: :monthly,
      title: 'Last 5 years, monthly'
    )
  end

  def quarterly_sparkline
    SparklinePresenter.new(
      QueryConditions::DocumentConditions.
        published_since('1994-01-01').
        deep_merge!(search_conditions),
      period: :quarterly,
      title: 'Since 1994, quarterly'
    )
  end

  def document_results
    OpenStruct.new(
      documents: agency.documents(per_page: 10),
      per_page: 10,
      search_conditions: agency.search_conditions,
      total_document_count: agency.total_document_count
    )
  end

  def public_inspection_document_results
    OpenStruct.new(
      documents: agency.public_inspection_documents(per_page: 10),
      per_page: 10,
      search_conditions: agency.search_conditions,
      total_document_count: agency.total_public_inspection_document_count
    )
  end

  def significant_document_results
    OpenStruct.new(
      documents: agency.significant_documents(per_page: 5),
      per_page: 5,
      search_conditions: agency.search_conditions.deep_merge!(
        conditions: {significant: 1}
      ),
      total_document_count: agency.total_significant_document_count
    )
  end
end
