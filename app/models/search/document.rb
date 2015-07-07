class Search::Document < Search::Base
  attr_reader :params
  attr_accessor :result_set,
    :errors,
    :regulatory_plan_count,
    :validation_errors,
    :conditions

  def search_type
    ::Document
  end

  #FACETS.each do |facet|
  #  define_method("#{facet}_facets") do
  #    conditions[facet.to_s.pluralize].present? || conditions["#{facet}_facets"].present?
  #  end
  #end
end
