class SuggestionService
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
      # narrowed_search_results: []
    )
  end

  def initialize(params)
    @params = params.to_hash.compact
    # @date = params.fetch(:date, nil)
    @prior_count = nil
    @query = params.fetch(:query, nil)
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

  def fr_search_metadata_result
    valid_conditions = fr_search.valid_conditions
    ::Document.search_metadata(conditions: valid_conditions)
  end

  def fr_search_suggestions
    search_details = fr_search.search_details

    return [] unless search_details.present? &&
      search_details.suggestions.present?

    SearchPresenter::Suggestions.new(search_details.suggestions)
      .suggestions
  end

  def fr_search
    Search::Document.new(conditions: {term: query})
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

    def search_suggestion?
      true
    end

    def prefer_content_path
      "http://www.google.com"
    end

    def reserved?
      false
    end

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
    fr_search_suggestions.map do |fr_search_suggestion|
      FrSearchSuggestion.new(
        type: 'cfr_reference',
        highlight: fr_search_suggestion.text,
        citation: "", #TODO: Populate if we want to surface the citation
        row_classes: ["suggestion"],
        toc_suffix: nil,
        usable_highlight: false,
        path: 'http://www.google.com',
        icon: 'baz',
        usable_highlight: '',
        kind: :total_search_results,
        removed: false
        # type: 'autocomplete'
        # hidden: false
      )
    end

    # ContentVersion.suggestions(
    #   params.merge(autocomplete: true)
    # )
  end
  memoize :search_suggestions

  private

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
