class PublicInspectionFacet < FederalRegister::Facet::PublicInspectionDocument::Type

  def search_conditions
    result_set.conditions.deep_merge(
      conditions: {
        type: slug
      }
    )
  end

end
