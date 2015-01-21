class AgencyFacet < FederalRegister::Facet::Agency
  def self.search(conditions={})
    super(conditions)
  end

  def search_conditions
    result_set.conditions.merge(
      conditions: {
        agencies: slug
      }
    )
  end
end
