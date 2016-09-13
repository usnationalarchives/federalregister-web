module Models
  module SearchHelpers
    def stubbed_conditions
      all_params = Search::Base::SEARCH_CONDITIONS.push(
        Search::Document::DOCUMENT_SEARCH_CONDITIONS.push(
          Search::PublicInspection::PUBLIC_INSPECTION_SEARCH_CONDITIONS
        )
      ).flatten

      all_conditions = {}
      all_params.each{|p| all_conditions[p]="stub"}
      all_conditions[:cfr] = {title: "stub", part: "stub"}
      all_conditions[:near] = {within: "stub", location: "stub"}

      all_conditions
    end
  end
end
