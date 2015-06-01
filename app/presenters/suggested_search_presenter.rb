class SuggestedSearchPresenter
  attr_reader :suggested_search, :section
  class InvalidSuggestedSearch < StandardError; end

  def initialize(slug)
    raise InvalidSuggestedSearch unless SuggestedSearch.find(slug)

    @suggested_search = SuggestedSearch.find(slug)
  end

  def description
    suggested_search.description
  end

  def documents
    raw_api_documents.
      results.map{|document| DocumentDecorator.decorate(document)}
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

  def search_conditions
    suggested_search.search_conditions
  end

  def section_slug
    suggested_search.section
  end

  def section_name
    Section.find_by_slug(suggested_search.section).try(:title)
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

  def title
    suggested_search.title
  end


  def docs_returned_total
    documents.count
  end

  def docs_overall_total
    raw_api_documents.count
  end

  private

  def raw_api_documents
    @api_documents ||= FederalRegister::Document.search(
      conditions: search_conditions,
      order: 'newest',
      per_page: 20)
  end
end
