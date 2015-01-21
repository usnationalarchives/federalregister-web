class TopicFacet < FederalRegister::Facet::Topic
  def self.search(conditions={})
    super(conditions)
  end

  def search_conditions
    result_set.conditions.merge(
      conditions: {
        topics: slug
      }
    )
  end
end
