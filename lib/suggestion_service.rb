class SuggestionService
  include ActionView::Helpers::NumberHelper
  extend Memoist

  # include SuggestionService::CustomPatterns

  QUERY_LENGTH_LIMIT = 128

  def self.perform(params)
    new(params).perform
  end

  attr_reader :date, :params, :prior_count, :prior_hierarchy, :query

  # delegate :metadata, to: :search_suggestions
  def metadata #FR-specific addition
    result = fr_search_metadata_result
    OpenStruct.new(
      global_search_results: result.count,
      narrowed_search_results: narrowed_search_results
    )
  end

  def initialize(params)
    @params = params.to_hash.compact
    # @date = params.fetch(:date, nil)
    @prior_count = nil
    @query = params.fetch(:query, nil)
    @agencies = params.fetch(:agencies, nil)
    # handle_hierarchy
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

  def narrowed_search_results
    fr_search_suggestions.each_with_object(Array.new) do |fr_search_suggestion, results|
      if ["SearchSuggestion::SearchRefinementSuggestion", "SearchSuggestion::PublicInspectionSuggestion"].include?(fr_search_suggestion.class.to_s)
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
      # Handle FR citations
      case fr_search_suggestion.class.to_s
      when "SearchSuggestion::CitationSuggestion"
        if fr_search_suggestion.matching_fr_entries.count == 0
          archives_citation = FrArchivesCitation.new(fr_search_suggestion.volume, fr_search_suggestion.page)
          if archives_citation.download_link_available?
            base_suggestion_attributes = {
              type: 'cfr_reference', #or 'autocomplete'
              citation: archives_citation.omni_search_citation, 
              row_classes: ["suggestion"],
              toc_suffix: nil,
              usable_highlight: false,
              icon: 'baz',
              fr_icon_class: "icon-fr2 icon-doctype icon-fr2-doc-pdf",
              usable_highlight: '',
              kind: :total_search_results,
              removed: false,
              reserved?: false,
              search_suggestion?: true,
              # hidden: false
            }

            if archives_citation.issue_slice_url
              results << FrSearchSuggestion.new(**base_suggestion_attributes.merge(
                highlight: "Digitized document PDF (#{number_to_human_size(archives_citation.optimized_file_size)})",
                path: archives_citation.issue_slice_url,
                prefer_content_path: archives_citation.issue_slice_url,
                page_range: archives_citation.issue_slice_page_range
              ))
            end

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


        page = fr_search_suggestion.page.to_i
        fr_search_suggestion.matching_fr_entries.each do |doc|
          path = doc.html_url
          if doc.start_page != page
            path << "#page-#{page}"
          end

          results << FrSearchSuggestion.new(
            type: 'cfr_reference', #or 'autocomplete'
            highlight: doc.title,
            citation: doc.citation, 
            row_classes: ["suggestion"],
            toc_suffix: nil,
            usable_highlight: false,
            path: path,
            icon: 'baz',
            fr_icon_class: doc.document_type.icon_class,
            usable_highlight: '',
            kind: :total_search_results,
            removed: false,
            page_range: doc.page_range,
            prefer_content_path: path,
            reserved?: false,
            search_suggestion?: true
            # hidden: false
          )
        end
      when "SearchSuggestion::DocumentNumberSuggestion"
        doc = fr_search_suggestion.document
        path = doc.html_url
        results << FrSearchSuggestion.new(
          type: 'cfr_reference', #or 'autocomplete'
          highlight: doc.title,
          citation: doc.document_number, 
          row_classes: ["suggestion"],
          toc_suffix: nil,
          usable_highlight: false,
          page_range: doc.page_range,
          path: path,
          icon: 'baz',
          fr_icon_class: doc.document_type.icon_class,
          usable_highlight: '',
          kind: :total_search_results,
          removed: false,
          prefer_content_path: path,
          reserved?: false,
          search_suggestion?: true
          # hidden: false
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
            icon: 'baz',
            fr_icon_class: autocomplete_suggestion.icon,
            usable_highlight: '',
            kind: :total_search_results,
            removed: false,
            prefer_content_path: "/d/#{autocomplete_suggestion.document_number}",
            reserved?: false,
            search_suggestion?: true
            # hidden: false
          )
      end
    end

    # ContentVersion.suggestions(
    #   params.merge(autocomplete: true)
    # )
  end
  memoize :search_suggestions

  private

  def fr_autocomplete_suggestions
    return [] unless Settings.feature_flags.omni_autocomplete

    AutocompleteSuggestion.suggestions(query)
  end

  def test_fr_search_suggestions
    # cache_for 1.day
    valid_conditions = Search::Document.new(params).valid_conditions
    begin
      count = ::Document.search_metadata(conditions: valid_conditions).count
    rescue FederalRegister::Client::BadRequest => e
      raise "TODO: Figure out handling"
    end

    url =  documents_search_path(conditions: valid_conditions)
  end


  # def handle_hierarchy
  #   hierarchy = @params.delete("hierarchy") || {}

  #   if hierarchy.present?
  #     hierarchy = CommonHierarchy.new(JSON.parse(hierarchy).stringify_keys)
  #     @params[:hierarchy] = hierarchy.to_hash.except(:complete)
  #     @prior_hierarchy = hierarchy.dup
  #   else
  #     @prior_hierarchy = {}
  #   end
  # end

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
