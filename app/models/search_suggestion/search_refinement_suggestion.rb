class SearchSuggestion::SearchRefinementSuggestion
  include SearchSuggestion::Shared

  attr_reader :conditions, :count, :search_conditions, :search_summary

  def initialize(options, conditions)
    @conditions = conditions
    @search_conditions = options["search_conditions"]
    @count = options["count"]
    @search_summary = options["search_summary"]
  end
end
