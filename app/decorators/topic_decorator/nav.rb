class TopicDecorator::Nav < TopicDecorator
  include NavigationBarFacetHelper
  def facet_conditions
    {:topics => identifier}
  end
end
