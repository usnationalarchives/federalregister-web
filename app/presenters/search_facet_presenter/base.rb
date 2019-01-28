class SearchFacetPresenter::Base
  PLURAL_FILTERS = [:topic_ids] # agency_ids; comment back in to be able to remove individual agencies

  attr_reader :params, :h

  def initialize(params, view_context)
    @params = params
    @h = view_context
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

  def link_to_search_filter(facet)
    h.link_to(
      facet.name,
      search_filter_path(facet.condition, facet.value),
      class: 'facet-name'
    )
  end

  def link_to_remove_search_filter(facet, &block)
    h.link_to(
      remove_search_filter_path(facet.condition, facet.value),
      title: 'Remove Filter',
      class: 'remove',
    ) do
      yield
    end
  end

  private

  def search_filter_path(condition, value)
    conditions = params.dup[:conditions] || {}

    if PLURAL_FILTERS.include?(condition)
      conditions[condition] ||= []
      conditions[condition] << value
    else
      conditions[condition] = value
    end
    params.except(:quiet, :all, :facet).recursive_merge(:page => nil, :action => :show, :conditions => conditions)
  end

  def remove_search_filter_path(condition, value)
    conditions = params.dup[:conditions] || {}

    if PLURAL_FILTERS.include?(condition)
      conditions[condition] ||= []
      conditions[condition] = conditions[condition] - [value.to_s]
    else
      conditions.except!(condition)
    end
    params.except(:quiet).merge(:page => nil, :action => :show, :conditions => conditions)
  end
end
