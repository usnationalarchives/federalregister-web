class SearchFacetPresenter::PublicInspection < SearchFacetPresenter::Base

  def search_type
    FederalRegister::PublicInspectionDocument
  end

  def agency_facets
    # RW: Not available yet
#  def self.define_facet(facet)
#    plural = facet.to_s.pluralize
#    define_method("#{facet}_facets") do
#      HTTParty.get(
#        api_pi_documents_facet_url(facet, params.to_param)
#      ).
#        map do |slug, data|
#          Facet.new(
#            value: slug,
#            name: data["name"],
#            count: data["count"],
#            condition: plural
#          )
#        end.sort{|a,b| b.count <=> a.count}
#    end
  end
end
