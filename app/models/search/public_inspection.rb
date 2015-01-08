class Search::PublicInspection < Search::Base
  attr_reader :params
  attr_accessor :result_set,
    :errors,
    :regulatory_plan_count,
    :validation_errors,
    :conditions,
    :special_filing

  def search_type
    FederalRegister::PublicInspectionDocument
  end

  FACETS = [:agency]
  FACETS.each do |facet|
    define_method("#{facet}_ids") do
      conditions[facet.to_s.pluralize].present? || conditions["#{facet}_ids"].present?
    end
  end
end
