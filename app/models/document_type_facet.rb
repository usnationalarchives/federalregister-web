class DocumentTypeFacet < FederalRegister::Facet::Document::Type
  DOCUMENT_TYPES = {
    "NOTICE" => "Notice",
    "PRESDOCU" => "Presidential Document",
    "PRORULE" => "Proposed Rule",
    "RULE" => "Rule",
  }

  def search_conditions
    result_set.conditions.deep_merge(
      conditions: {
        type: Array(slug)
      }
    )
  end

  def type
    DOCUMENT_TYPES[slug]
  end
end
