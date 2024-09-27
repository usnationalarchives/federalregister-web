class SearchSuggestion::AgencySuggestion
  include SearchSuggestion::Shared
  
  attr_reader :agency_slug, :agency_name

  def initialize(options, conditions)
    @conditions  = conditions
    @agency_slug = options["agency_slug"]
    @agency_name = options["agency_name"]
  end

end
