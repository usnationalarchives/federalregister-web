class SearchSuggestion::SearchRefinementSuggestion
  include SearchSuggestion::Shared

  attr_reader :conditions, :count, :search_conditions, :search_summary

  def initialize(options, conditions)
    @conditions = conditions
    @search_conditions = options["search_conditions"]
    @count = options["count"]
    @search_summary = options["search_summary"]
  end

  def omni_search_scope_description
    search_summary
  end

  def icon_name
    "Search"
  end

end
