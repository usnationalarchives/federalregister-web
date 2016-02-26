class Search::Document < Search::Base
  attr_reader :params
  attr_accessor :result_set,
    :errors,
    :regulatory_plan_count,
    :validation_errors,
    :conditions

  DOCUMENT_SEARCH_CONDITIONS = [
    :publication_date,
    :effective_date,
    :citing_document_numbers,
    :comment_date,
    :small_entity_ids,
    :presidential_document_type,
    :president,
    :section_ids,
    :significant,
    :regulation_id_number,
    :cfr,
    :near,
    :topics,
    :sections,
    :correction
  ]

  def search_type
    ::Document
  end

  def public_inspection_document_count
    PublicInspectionDocument.search_metadata(
      conditions: Search::PublicInspection.new(conditions).
        valid_conditions.symbolize_keys
    ).count
  end

  #FACETS.each do |facet|
  #  define_method("#{facet}_facets") do
  #    conditions[facet.to_s.pluralize].present? || conditions["#{facet}_facets"].present?
  #  end
  #end

  (SEARCH_CONDITIONS + DOCUMENT_SEARCH_CONDITIONS).each do |param|
    define_method(param) do
      conditions[param]
    end
  end
end
