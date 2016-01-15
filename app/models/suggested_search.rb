class SuggestedSearch < FederalRegister::SuggestedSearch
  def documents
    Document.search(
      conditions: search_conditions
    ).results
  end

  def self.slugs
    return @suggested_search_slugs if @suggested_search_slugs

    response = search

    @suggested_search_slugs = response.map do |section, searches|
      searches.collect{|search| search.slug}
    end.flatten
  end
end
