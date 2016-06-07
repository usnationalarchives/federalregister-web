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
    ::Document.search_metadata(
      conditions: Search::Document.new(conditions).
        valid_conditions.symbolize_keys
    ).count
  end

  (SEARCH_CONDITIONS + PUBLIC_INSPECTION_SEARCH_CONDITIONS).each do |param|
    define_method(param) do
      conditions[param]
    end
  end
end
