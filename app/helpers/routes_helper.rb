module RoutesHelper
  def entries_search_path(params)
    "/articles/search?#{params.to_query}"
  end

  def entries_search_feed_url(params)
    "https://www.federalregister.gov/articles/search.rss?#{params.to_query}"
  end
end
