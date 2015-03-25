class SuggestedSearch < FederalRegister::SuggestedSearch

  def example_documents
    FederalRegister::Document.search(:conditions => search_conditions).results
  end

end