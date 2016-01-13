class TopicPresenter
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
