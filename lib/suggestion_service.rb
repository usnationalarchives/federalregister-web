class SuggestionService
  include ActionView::Helpers::NumberHelper
  extend Memoist

  include SuggestionService::CustomPatterns

  QUERY_LENGTH_LIMIT = 128

  def self.perform(params)
    new(params).perform
  end

  attr_reader :date, :params, :prior_count, :prior_hierarchy, :query

  def metadata #FR-specific addition (ECFR delegates metadata to search_suggestions)
    result = fr_search_metadata_result
    OpenStruct.new(
      global_search_results: result.count,
      narrowed_search_results: narrowed_search_results,
      public_inspection_search_results: public_inspection_search_results
    )
  end

  def initialize(params)
    @params = params.to_hash.compact
    @prior_count = nil
    @query = params.fetch(:query, nil)
    @agencies = params.fetch(:agencies, nil)
  end

  def perform
    return [] unless valid?

    suggestions = [
      custom_suggestions,
      search_suggestions#.all
    ].flatten.compact

    @prior_count = metadata.narrowed_search_results

    deduplicate(suggestions)
  end

  def valid?
    query.present? && (query.length <= QUERY_LENGTH_LIMIT)
  end

  private

  attr_reader :agencies

  def public_inspection_search_results
    fr_search_suggestions.each_with_object(Array.new) do |fr_search_suggestion, results|
      if [ "SearchSuggestion::PublicInspectionSuggestion"].include?(fr_search_suggestion.class.to_s)
        results << fr_search_suggestion
      end
    end
  end

  def narrowed_search_results
    fr_search_suggestions.each_with_object(Array.new) do |fr_search_suggestion, results|
      if ["SearchSuggestion::SearchRefinementSuggestion"].include?(fr_search_suggestion.class.to_s)
        results << fr_search_suggestion
      end
    end
  end

  def fr_search_metadata_result
    valid_conditions = fr_search.valid_conditions
    ::Document.search_metadata(conditions: valid_conditions)
  end

  def fr_search_suggestions
    search_details = fr_search.suggestion_search_details

    return [] unless search_details.present? &&
      search_details.suggestions.present?

    search_details.
      suggestions.
      sort_by do |suggestion|
        SearchPresenter::Suggestions::SUGGESTIONS_ORDER.index(
          suggestion.class.name.demodulize.snakecase
        )
      end
  end
  memoize :fr_search_suggestions

  def fr_search
    Search::Document.new(fr_search_parameters)
  end

  def fr_search_parameters
    {conditions: {term: query}}.tap do |fr_params|
      if agencies
        fr_params[:conditions][:agencies] = agencies
      end
    end
  end

  def custom_suggestions
    return []

    CUSTOM_PATTERNS.map do |details|
      if details[:pattern].match?(query)
        ContentVersion::Suggestion.new( #Seems like this references the ECFR gem
          details.except(:pattern).deep_stringify_keys
        )
      end
    end.compact
  end

  class FrSearchSuggestion < OpenStruct
    attr_reader :type

    def method_missing(method_name, *args, &block)
      # eg flag method call errors
      if @table.key?(method_name.to_sym) || @table.key?(method_name.to_s.chomp('=').to_sym)
        super
      else
        raise NoMethodError, "undefined method `#{method_name}` for #{self}"
      end
    end
  end

  def search_suggestions
    fr_search_suggestions.each_with_object(Array.new) do |fr_search_suggestion, results|
      # NOTE: Someday it may make sense to refactor these attributes into their respective classes
      case fr_search_suggestion.class.to_s
      when "SearchSuggestion::CitationSuggestion"
        # FR Archives Suggestion
        if fr_search_suggestion.matching_fr_entries.count == 0
          archives_citations = FrArchivesClient.citations(fr_search_suggestion.volume, fr_search_suggestion.page)
          if archives_citations.any?(&:download_link_available?)
            omni_search_citation = archives_citations.first.omni_search_citation
            base_suggestion_attributes = {
              type: 'cfr_reference',
              citation: omni_search_citation, 
              row_classes: ["suggestion"],
              toc_suffix: nil,
              usable_highlight: false,
              fr_icon_class: "doc-pdf",
              usable_highlight: '',
              kind: :total_search_results,
              removed: false,
              search_suggestion?: true,
            }

            archives_citations.each do |archives_citation|
              if archives_citation.issue_slice_url
                results << FrSearchSuggestion.new(**base_suggestion_attributes.merge(
                  highlight: "Digitized partial issue page range PDF (#{number_to_human_size(archives_citation.optimized_file_size)})",
                  path: archives_citation.issue_slice_url,
                  prefer_content_path: archives_citation.issue_slice_url,
                  page_range: archives_citation.issue_slice_page_range
                ))
              end
            end

            archives_citation = archives_citations.first
            results << FrSearchSuggestion.new(**base_suggestion_attributes.merge(
              highlight: "Digitized full issue PDF containing #{archives_citation.omni_search_citation} (#{number_to_human_size(archives_citation.original_file_size)})",
              path: archives_citation.gpo_url,
              page_range: nil,
              prefer_content_path: archives_citation.gpo_url
            ))
          else
            next
          end
        end

        # Non-FR Archives (Standard) Suggestions
        page = fr_search_suggestion.page.to_i
        fr_search_suggestion.matching_fr_entries.each do |doc|
          path = doc.html_url
          if doc.start_page != page
            path << "#page-#{page}"
          end

          results << FrSearchSuggestion.new(
            type: 'cfr_reference',
            highlight: doc.title,
            citation: doc.citation, 
            row_classes: ["suggestion"],
            toc_suffix: nil,
            usable_highlight: false,
            path: path,
            fr_icon_class: doc.document_type.identifier,
            usable_highlight: '',
            kind: :total_search_results,
            removed: false,
            page_range: doc.page_range,
            prefer_content_path: path,
            search_suggestion?: true
          )
        end
      when "SearchSuggestion::DocumentNumberSuggestion"
        doc = fr_search_suggestion.document
        path = doc.html_url
        results << FrSearchSuggestion.new(
          type: 'cfr_reference',
          highlight: doc.title,
          citation: doc.document_number, 
          row_classes: ["suggestion"],
          toc_suffix: nil,
          usable_highlight: false,
          page_range: doc.page_range,
          path: path,
          fr_icon_class: doc.document_type.identifier,
          usable_highlight: '',
          kind: :total_search_results,
          removed: false,
          prefer_content_path: path,
          search_suggestion?: true
        )
      when "SearchSuggestion::AgencySuggestion"
        path = "/agencies/#{fr_search_suggestion.agency_slug}"
        results << FrSearchSuggestion.new(
          type: 'cfr_reference',
          highlight: "#{fr_search_suggestion.agency_name}",
          citation: fr_search_suggestion.agency_short_name, 
          row_classes: ["suggestion"],
          toc_suffix: nil,
          usable_highlight: false,
          page_range: nil,
          path: path,
          fr_icon_class: "network-alt",
          usable_highlight: '',
          kind: :total_search_results,
          removed: false,
          prefer_content_path: path,
          search_suggestion?: true
        )
      when "SearchSuggestion::IssueSuggestion"
        path = "/documents/#{fr_search_suggestion.date.to_s(:ymd)}"
        results << FrSearchSuggestion.new(
          type: 'cfr_reference',
          highlight: "Document Issue",
          citation: fr_search_suggestion.date.to_s(:default), 
          row_classes: ["suggestion"],
          toc_suffix: nil,
          usable_highlight: false,
          page_range: nil,
          path: path,
          fr_icon_class: "book-alt-2",
          usable_highlight: '',
          kind: :total_search_results,
          removed: false,
          prefer_content_path: path,
          search_suggestion?: true
        )

        path = "/documents/#{fr_search_suggestion.date.to_s(:ymd)}"
        results << FrSearchSuggestion.new(
          type: 'cfr_reference',
          highlight: "Public Inspection Issue",
          citation: fr_search_suggestion.date.to_s(:default), 
          row_classes: ["suggestion"],
          toc_suffix: nil,
          usable_highlight: false,
          page_range: nil,
          path: path,
          fr_icon_class: "clipboards",
          usable_highlight: '',
          kind: :total_search_results,
          removed: false,
          prefer_content_path: path,
          search_suggestion?: true
        )
      end

      end.tap do |results|
        fr_autocomplete_suggestions.each do |autocomplete_suggestion|
          results << FrSearchSuggestion.new(
            type: 'autocomplete',
            highlight: autocomplete_suggestion.search_term_completion,
            citation: "FR Doc. #{autocomplete_suggestion.document_number}",
            row_classes: ["suggestion"],
            toc_suffix: nil,
            usable_highlight: false,
            path: "/d/#{autocomplete_suggestion.document_number}",
            fr_icon_class: autocomplete_suggestion.icon,
            usable_highlight: '',
            kind: :total_search_results,
            removed: false,
            prefer_content_path: "/d/#{autocomplete_suggestion.document_number}",
            search_suggestion?: true
            # hidden: false
          )
      end
    end
  end
  memoize :search_suggestions

  private

  def fr_autocomplete_suggestions
    return [] unless Settings.feature_flags.omni_autocomplete

    AutocompleteSuggestion.suggestions(query)
  end

  def deduplicate(suggestions)
    suggestions.select do |suggestion|
      # don't attempt dedup unless it's a custom type
      if suggestion.type != "custom"
        true
      else
        # only return the suggestion if there isn't already a match in the
        # search suggestions
        !matching_suggestion_from_search?(suggestion, suggestions)
      end
    end
  end

  def matching_suggestion_from_search?(suggestion, suggestions)
    suggestions.any? do |s|
      (s.type != "custom") && (s.hierarchy == suggestion.hierarchy)
    end
  end
end
