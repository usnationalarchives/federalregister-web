class SearchSuggestion
  module Shared
    def to_partial_path
      "search/documents/suggestions/#{self.class.name.underscore.split("/").last}"
    end

    def public_inspection
      OpenStruct.new(
        count: suggestions["public_inspection"]["count"]
      )
    end
  end

  CLASSES = {
    "document_number" => SearchSuggestion::DocumentNumber,
    "cfr" => SearchSuggestion::CFR,
    "search_refinement" => SearchSuggestion::SearchRefinement,
    "citation" => SearchSuggestion::Citation,
    "public_inspection" => SearchSuggestion::PublicInspection
  }

  def self.build(type, details, conditions)
    if CLASSES[type]
      CLASSES[type].new(details, conditions)
    end
  end
end
