class SuggestedSearchPresenter
  include RouteBuilder::Fr2ApiUrls

  attr_reader :suggested_search, :section
  class InvalidSuggestedSearch < StandardError; end

  delegate :description, :search_conditions, :title, to: :@suggested_search

  def initialize(slug)
    @suggested_search = SuggestedSearch.find(slug)
    raise InvalidSuggestedSearch unless @suggested_search

    @section = Section.find_by_slug(@suggested_search.section)
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
      url: documents_search_api_path(
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
      metadata_only: 1
    ).count
  end
end
