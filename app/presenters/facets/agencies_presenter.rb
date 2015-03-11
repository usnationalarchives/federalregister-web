class Facets::AgenciesPresenter
  HIGHLIGHTED_AGENCIES = [
    "agriculture-department",
    "commerce-department",
    "defense-department",
    "education-department",
    "energy-department",
    "environmental-protection-agency",
    "health-and-human-services-department",
    "homeland-security-department",
    "housing-and-urban-development-department",
    "interior-department",
    "justice-department",
    "labor-department",
    "state-department",
    "transportation-department",
    "treasury-department",
    "veterans-affairs-department",
  ]

  def agencies_for_exploration
    @agencies ||= document_counts.
      select{|facet| HIGHLIGHTED_AGENCIES.include?(facet.slug)}.
      map{|facet|
        Agency.new(
          name: facet.name,
          slug: facet.slug,
          document_count: facet.count,
          document_count_search_conditions: facet.search_conditions,
          comment_count: comment_counts.detect{|x| x.slug == facet.slug}.try(:count) || 0,
          comment_count_search_conditions: comment_counts.detect{|x| x.slug == facet.slug}.try(:search_conditions)
        )
      }.
      map{|agency| AgencyFacetDecorator.decorate(agency)}.
      sort_by(&:name)
  end

  class Agency
    vattr_initialize [
      :comment_count,
      :comment_count_search_conditions,
      :document_count,
      :document_count_search_conditions,
      :name,
      :slug,
    ]
  end

  private

  def document_counts
    AgencyFacet.search(
      Facets::QueryConditions.published_in_last(1.week)
    )
  end

  def comment_counts
    @comments_counts ||= AgencyFacet.search(
      Facets::QueryConditions.comment_period_closing_in(1.week)
    )
  end
end
