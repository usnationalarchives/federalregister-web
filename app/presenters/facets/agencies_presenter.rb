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
    "veterans-affairs-department"
  ]

  def agencies_for_exploration
    @agencies ||= document_counts. #We receive back a hash of counts (Facet search results come back in JSON and get wrapepd into a Ruby obj)
      select{|facet| HIGHLIGHTED_AGENCIES.include?(facet.slug)}. #Selecting the highlighted slugs
      map{|facet| #creating new agencies 
        Agency.new(
          name: facet.name,
          slug: facet.slug,
          document_count: facet.count,
          document_count_search_conditions: facet.search_conditions,
          comment_count: comment_counts.detect{|x| x.slug == facet.slug}.try(:count) || 0,
          comment_count_search_conditions: comment_counts.detect{|x| x.slug == facet.slug}.try(:search_conditions)
        )
      }.
      map{|agency| AgencyFacetDecorator.decorate(agency)}. # We pass to a decorator
      sort_by(&:name) #Sorting by name
  end

  # See lines above for alternate initialization sequence, error message is also a little nicer
  # You can call all the respective methods
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
      Facets::QueryConditions.published_in_last(1.year)
    )
  end

  def comment_counts
    @comments_counts ||= AgencyFacet.search(
      Facets::QueryConditions.comment_period_closing_in(1.week)
    )
  end
end
