module RoutesHelper
  def entries_search_path(params)
    "/articles/search?#{params.to_query}"
  end
end