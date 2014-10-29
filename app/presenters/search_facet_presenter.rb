class SearchFacetPresenter < SearchPresenter
  def facets
    self.send(params[:facet] + "_facets").reject(&:on?)
  end

  def facets_available
    facets.present? && 
      !facets.detect{|facet| facet.value == "errors"} && 
      facets.map(&:count).detect{|x| x != 0} 
  end

  def facet_name
    params[:facet].humanize.capitalize_first
  end

  def num_facets
    params[:num_facets].try(:to_i) || 5
  end

  def publication_date_facets
    begin
      facets = [30,90,365].map do |n|
        value = n.days.ago.to_date.to_s(:year_month_day)
        count = FederalRegister::Article.search_metadata(
          conditions: conditions.merge(effective_date: {gte: value})
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
  #memoize :publication_date_facets

  def type_facets
    begin
      [["Rule", "RULE"],["Notice", "NOTICE"], ["Proposed Rule", "PRORULE"]].map do |name, identifier|
        count = FederalRegister::Article.search_metadata(
          conditions: conditions.merge(type: identifier)
        ).count
        Facet.new(
          value: {type: identifier},
          name: name,
          count: count,
          condition: :type
        )
      end.sort{|a,b| b.count <=> a.count}
    rescue FederalRegister::Client::BadRequest => e
      []
    end
  end
  #memoize :type_facets

  def self.define_facet(facet)
    plural = facet.to_s.pluralize
    define_method("#{facet}_facets") do
      HTTParty.get("https://www.federalregister.gov/api/v1/articles/facets/#{facet}?#{params.to_param}").
        map do |slug, data|
          Facet.new(
            value: slug,
            name: data["name"],
            count: data["count"],
            condition: plural
          )
        end.sort{|a,b| b.count <=> a.count}
    end
  end
  Search::FACETS.each { |facet| define_facet(facet) }
end
