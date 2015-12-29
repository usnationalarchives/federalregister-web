class SuggestedSearch < FederalRegister::SuggestedSearch
  def documents
    Document.search(
      conditions: search_conditions
    ).results
  end
end
