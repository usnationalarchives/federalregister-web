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
    "document_number"   => SearchSuggestion::DocumentNumberSuggestion,
    "cfr"               => SearchSuggestion::CFRSuggestion,
    "search_refinement" => SearchSuggestion::SearchRefinementSuggestion,
    "citation"          => SearchSuggestion::CitationSuggestion,
    "public_inspection" => SearchSuggestion::PublicInspectionSuggestion,
    "explanatory"       => SearchSuggestion::ExplanatorySuggestion,
    "agency"            => SearchSuggestion::AgencySuggestion,
    "issue"             => SearchSuggestion::IssueSuggestion,
  }

  def self.build(type, details, conditions)
    if CLASSES[type]
      CLASSES[type].new(details, conditions)
    end
  end
end
