class SuggestedSearchPresenter
  include RouteBuilder::Documents

  attr_reader :suggested_search, :section
  class InvalidSuggestedSearch < StandardError; end

  delegate :search_conditions, :title, to: :@suggested_search

  def initialize(slug)
    @suggested_search = SuggestedSearch.find(slug)
    raise InvalidSuggestedSearch unless @suggested_search

    @section = Section.find_by_slug(@suggested_search.section)
  end

  def description
    suggested_search.description
  end

  def documents
    @documents ||= Document.search(
      conditions: search_conditions,
      order: 'newest',
      per_page: per_page
    ).map{|document| DocumentDecorator.decorate(document)}
  end

  def per_page
    20
  end

  def feed_urls
    feeds = []

    feeds << FeedAutoDiscovery.new(
      url: documents_search_api_url(
        {conditions: search_conditions.except(:near)},
        format: :rss
      ),
      description: Search::Document.new(
        conditions: search_conditions.except(:near)
      ).summary,
      search_conditions: search_conditions.except(:near)
    )

    feeds
  end

  def total_documents
    @total_documents ||= Document.search(
      conditions: search_conditions,
      metadata_only: true
    ).count
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
end
