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
end
