class SearchDetails::PublicInspectionDocument < SearchDetails::Base
  def response
    @response ||= FederalRegister::PublicInspectionDocumentSearchDetails.search(conditions: conditions)
  end
end