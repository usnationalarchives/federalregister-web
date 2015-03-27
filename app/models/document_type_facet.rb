class DocumentTypeFacet < FederalRegister::Facet::Document::Type
  def search_conditions
    result_set.conditions.deep_merge(
      conditions: {
        type: slug
      }
    )
  end
end
