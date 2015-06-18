class SuggestedSearchPresenter
  attr_reader :suggested_search, :section
  class InvalidSuggestedSearch < StandardError; end

  delegate :search_conditions, :title, to: :@suggested_search

  def initialize(slug)
    raise InvalidSuggestedSearch unless SuggestedSearch.find(slug)

    @suggested_search = SuggestedSearch.find(slug)
    @section = Section.find_by_slug(@suggested_search.section)
  end

  def description
    suggested_search.description
  end

  def documents
    @documents ||= Document.search(
      conditions: search_conditions,
      order: 'newest',
      per_page: 20
    ).map{|document| DocumentDecorator.decorate(document)}
  end

  def feed_urls
    feeds = []
    feeds << FeedAutoDiscovery.new(
      url: '',
      public_inspection_search_possible: public_inspection_search_possible?,
      description: modal_description,
      search_conditions: search_conditions
    )
    feeds
  end

  def modal_description
    "Documents matching '#{terms}'" #There should be a helper to account for
    #sections and descriptions
  end

  def public_inspection_search_possible?
    begin
      FederalRegister::PublicInspectionDocument.search_metadata(search_conditions)
      true
    rescue FederalRegister::Client::BadRequest
      false
    end
  end

  def terms
    search_conditions["term"]
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
        published_within('1994-01-01', DocumentIssue.current.publication_date).
        deep_merge!(search_conditions),
      period: :quarterly,
      title: 'Since 1994, quarterly'
    )
  end
end
