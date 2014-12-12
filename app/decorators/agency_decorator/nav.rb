class AgencyDecorator::Nav < AgencyDecorator
  include NavigationBarFacetHelper
  def facet_conditions
    {:agency_ids => id}
  end
end
