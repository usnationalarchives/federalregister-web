class TopicPresenter
  include RouteBuilder::Fr2ApiUrls

  attr_reader :topic
  class InvalidTopic < StandardError; end

  delegate :documents,
    :name,
    :per_page,
    :search_conditions,
    :slug,
    :total_document_count, to: :@topic

  def initialize(slug)
    @topic = TopicFacet.search.detect{|topic| topic.slug == slug}
    raise InvalidTopic unless @topic
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
end
