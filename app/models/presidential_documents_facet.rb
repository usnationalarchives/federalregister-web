class PresidentialDocumentsFacet < FederalRegister::Facet::PresidentialDocumentType
  def self.search(conditions={})
    super(conditions)
  end

  def search_conditions
    result_set.conditions.deep_merge(
      conditions: {
        presidential_document_type: slug
      }
    )
  end

end
