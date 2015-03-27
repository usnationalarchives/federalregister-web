class SuggestedSearchPresenter
  attr_reader :suggested_search, :section

  def initialize(suggested_search)
    @suggested_search = suggested_search
  end


  def description
    suggested_search.description
  end

  def documents
    @documents ||= FederalRegister::Document.search(
      conditions: search_conditions,
      order: 'newest',
      per_page: 20).
      results.map{|document| DocumentDecorator.decorate(document)
    }
  end

  def search_conditions
    suggested_search.search_conditions
  end

  def section
    "Test Section"
  end

  def title
    @suggested_search.title
  end

  def total_docs
    documents.count
  end

end