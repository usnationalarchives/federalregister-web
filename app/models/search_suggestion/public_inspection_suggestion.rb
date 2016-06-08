class SearchSuggestion::PublicInspectionSuggestion
  include SearchSuggestion::Shared

  attr_reader :conditions, :count

  def initialize(options, conditions)
    @conditions = conditions
    @count = options["count"]
  end
end
