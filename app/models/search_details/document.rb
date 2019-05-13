class SearchDetails::Document < SearchDetails::Base
  def response
    @response ||= FederalRegister::DocumentSearchDetails.search(conditions: conditions)
  end
end