class AgencyFacet < FederalRegister::Facet::Agency
  def self.search(conditions={})
    super(conditions)
  end

  def search_conditions
    result_set.conditions.deep_merge(
      conditions: {
        agencies: slug
      },
      order: 'newest'
    )
  end
end
