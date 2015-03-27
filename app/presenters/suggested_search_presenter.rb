class SuggestedSearchPresenter
  attr_reader :suggested_search, :section
  class InvalidSuggestedSearch < StandardError; end

  def initialize(suggested_search)
    raise InvalidSuggestedSearch unless suggested_search.is_a? SuggestedSearch #TODO: Evaluate validation here.
    @suggested_search = suggested_search
  end

  def description
    suggested_search.description
  end

  def documents
    raw_api_documents.
      results.map{|document| DocumentDecorator.decorate(document)}
  end

  def search_conditions
    suggested_search.search_conditions
  end

  def section
    "Test Section" #TODO: Implement from TBD API parameter
  end

  def title
    @suggested_search.title
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