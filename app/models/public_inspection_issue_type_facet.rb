class PublicInspectionIssueTypeFacet < FederalRegister::Facet::PublicInspectionIssue::Type
  def search_conditions(type)
    conditions.deep_merge(
      conditions: {
        type: type
      }
    )
  end
end
