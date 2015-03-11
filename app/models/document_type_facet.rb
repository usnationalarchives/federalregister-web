class DocumentTypeFacet < FederalRegister::Facet::Document::Type
  def self.search(conditions={})
    super(conditions)
  end

  def search_conditions
    result_set.conditions.deep_merge(
      conditions: {
        type: slug
      }
    )
  end

end
