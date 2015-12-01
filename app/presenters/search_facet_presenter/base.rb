class SearchFacetPresenter::Base
  attr_reader :params
  def initialize(params)
    @params = params
  end

  def facets
    Array(self.send(params[:facet] + "_facets")).
      reject{|x| x.on? || x.count == 0}
  end

  def conditions
    params["conditions"] || {}
  end

  def facet_name
    params[:facet].humanize.capitalize_first
  end

  def facets_available?
    facets.present? &&
      facets.none?{|facet| facet.value == "errors"} &&
      facets.map(&:count).any?{|x| x != 0}
  end

  def num_facets
    params[:num_facets].try(:to_i) || 5
  end

  def type_facets
    begin
      [
        ["Rule", "RULE"],
        ["Notice", "NOTICE"],
        ["Proposed Rule", "PRORULE"],
        ["Presidential Document", "PRESDOCU"],
      ].map do |name, identifier|
        count = search_type.search_metadata(
          conditions: conditions.merge(type: identifier)
        ).count
        Facet.new(
          value: identifier,
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
end
