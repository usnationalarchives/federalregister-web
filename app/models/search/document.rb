class Search::Document < Search::Base
  attr_reader :params
  attr_accessor :result_set,
    :errors,
    :regulatory_plan_count,
    :validation_errors,
    :conditions

  DOCUMENT_SEARCH_CONDITIONS = [
    :cfr,
    :citing_document_numbers,
    :comment_date,
    :correction,
    :effective_date,
    :near,
    :president,
    :presidential_document_type,
    :publication_date,
    :regulation_id_number,
    :section_ids,
    :sections,
    :significant,
    :small_entity_ids,
    :topics,
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

  (SEARCH_CONDITIONS + DOCUMENT_SEARCH_CONDITIONS).each do |param|
    define_method(param) do
      conditions[param]
    end
  end
end
