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
    :presidential_document_type_id,
    :publication_date,
    :regulation_id_number,
    :search_type_ids,
    :section_ids,
    :sections,
    :significant,
    :signing_date,
    :small_entity_ids,
    :topics,
    :topic_ids
  ]

  def search_type
    ::Document
  end

  def search_details
    @search_details ||= SearchDetails::Document.new(conditions)
  end

  def near
    OpenStruct.new(
      location: conditions[:near].try(:[], :location),
      within: (conditions[:near].try(:[], :within))
    )
  end

  def public_inspection_document_count
    PublicInspectionDocument.search_metadata(
      conditions: Search::PublicInspection.new(conditions).
        valid_conditions.symbolize_keys
    ).count
  end

  (SEARCH_CONDITIONS + DOCUMENT_SEARCH_CONDITIONS).each do |param|
    define_method(param) do
      conditions[param.to_sym]
    end
  end
end
