class SearchSuggestion::PublicInspectionSuggestion
  include SearchSuggestion::Shared

  attr_reader :conditions, :count

  def initialize(options, conditions)
    @conditions = conditions
    @count = options["count"]
  end

  def  omni_search_scope_description
    "scheduled for publication on Public Inspection that match your search"
  end

  def icon_name
    "clipboards"
  end

end
