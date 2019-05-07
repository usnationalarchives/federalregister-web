class SearchFacetPresenter::PublicInspection < SearchFacetPresenter::Base
  FACETS = [:agency, :agencies, :type]

  def search_type
    ::PublicInspectionDocument
  end

  def self.define_facet(facet)
    define_method("#{facet}_facets") do
      results = "FederalRegister::Facet::PublicInspectionDocument::#{facet.capitalize}".
        constantize.
        search(params)

      results.map do |result|
        Facet.new(
          value: result.slug,
          name: result.name,
          count: result.count,
          condition: facet == :type ? facet.to_s : facet.to_s.pluralize
        )
      end.sort{|a,b| b.count <=> a.count}
    end
  end

  FACETS.each { |facet| define_facet(facet) }
end
