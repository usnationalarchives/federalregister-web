class SearchFacetPresenter::Document < SearchFacetPresenter::Base
  attr_reader :params

  FACETS = [:agency, :section, :topic, :type]

  def search_type
    ::Document
  end

  def publication_date_facets
    begin
      facets = [30,90,365].map do |n|
        value = (Date.current - n.days).to_s(:date)
        count = search_type.search_metadata(
          conditions: conditions.merge(publication_date: {gte: value})
        ).count
        Facet.new(
          value: {gte: value},
          name: "Past #{n} days",
          count: count,
          condition: :publication_date
        )
      end
    rescue FederalRegister::Client::BadRequest => e
      add_errors(e)
      []
    end
  end
  # RW: memoize
  #
  def self.define_facet(facet)
    define_method("#{facet}_facets") do
      results = "FederalRegister::Facet::Document::#{facet.capitalize}".
        constantize.
        search(params.slice('conditions'))

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
