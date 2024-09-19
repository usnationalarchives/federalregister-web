class SearchDetails::SuggestionServiceDocument < SearchDetails::Base
  def response
    @response ||= FederalRegister::DocumentSearchDetails.search(conditions: conditions, omit_spelling_suggestions: true)
  end
end
