class SearchSuggestion::IssueSuggestion
  include SearchSuggestion::Shared

  attr_reader :date
  
  def initialize(options, conditions)
    @conditions  = conditions
    @date        = Date.parse(options.fetch("date"))
  end

end
