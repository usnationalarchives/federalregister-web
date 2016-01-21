class WpApi::SearchResult
  attr_reader :term, :page_collection, :post_collection

  def initialize(term, page_collection, post_collection)
    @term = term
    @page_collection = page_collection
    @post_collection = post_collection
  end

  def count
    page_collection.pages.count + post_collection.posts.count
  end

  def display_term
    term.html_safe
  end
end
