class SuggestedSearchContraint
  def matches?(request)
    suggested_search_slugs.include?(request.path_parameters[:slug])
  end

  def suggested_search_slugs
    return @suggested_search_slugs if @suggested_search_slugs

    @suggested_search_slugs = []

    unless Rails.env.test?
      begin
        @suggested_search_slugs = SuggestedSearch.slugs
      rescue StandardError => e
        Honeybadger.notify(e)
      end
    end
  end
end
