class SuggestedSearchContraint
  def initialize
    @suggested_search_slugs = Rails.env.test? ? [] : SuggestedSearch.slugs
  end

  def matches?(request)
    @suggested_search_slugs.include?(request.path_parameters[:slug])
  end
end
