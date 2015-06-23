class SuggestedSearch < FederalRegister::SuggestedSearch

  def documents
    FederalRegister::Document.search(:conditions => search_conditions).results
  end

end
