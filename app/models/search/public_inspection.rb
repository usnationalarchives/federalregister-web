class Search::PublicInspection < Search::Base
  attr_reader :params
  attr_accessor :result_set,
    :errors,
    :regulatory_plan_count,
    :validation_errors,
    :conditions,
    :special_filing

  PUBLIC_INSPECTION_SEARCH_CONDITIONS = [
    :special_filing
  ]

  def search_type
    ::PublicInspectionDocument
  end

  def document_count
    FederalRegister::Document.search_metadata(
      conditions: valid_conditions.
        symbolize_keys.
        except(*PUBLIC_INSPECTION_SEARCH_CONDITIONS)
    ).count
  end

  FACETS = [:agency]
  FACETS.each do |facet|
    define_method("#{facet}_ids") do
      conditions[facet.to_s.pluralize].present? || conditions["#{facet}_ids"].present?
    end
  end

  (SEARCH_CONDITIONS + PUBLIC_INSPECTION_SEARCH_CONDITIONS).each do |param|
    define_method(param) do
      conditions[param]
    end
  end
end
