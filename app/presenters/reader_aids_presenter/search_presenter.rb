class ReaderAidsPresenter::SearchPresenter < ReaderAidsPresenter::Base
  attr_reader :results

  def initialize(term)
    @results = WpApi::Client.search(term)
  end

  def result_count
    results.count
  end

  def search_term
    results.display_term
  end

  def posts
    results.post_collection.posts
  end

  def grouped_pages
    results.page_collection.pages_grouped_by_parent
  end

  def parent_section(parent)
    sections[parent.slug]
  end
end
