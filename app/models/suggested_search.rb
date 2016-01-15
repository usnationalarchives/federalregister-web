class SuggestedSearch < FederalRegister::SuggestedSearch
  def documents
    Document.search(
      conditions: search_conditions
    ).results
  end

  def self.slugs
    @suggested_search_slugs ||= search.map do |section, searches|
      searches.collect{|search| search.slug}
    end.flatten
  end
end
