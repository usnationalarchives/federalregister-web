class SuggestionsPresenter < ApplicationPresenter
  extend Memoist
  include ActionView::Helpers::NumberHelper
  # include SearchPresenter::OfflineTolerant

  attr_reader :service, :suggestions

  delegate :date, :metadata, :prior_count, :prior_hierarchy, :query,
    to: :service, allow_nil: true

  delegate :global_search_results, :narrowed_hierarchy, :narrowed_search_results,
    to: :metadata, allow_nil: true

  def initialize(params)
    # VERIFY: don't pass prior_hierarchy along as this is a new request cycle?
    @service = SuggestionService.new(
      params.except(:prior_hierarchy)
    )
  end

  def results
    # guard_search_offline do
      @suggestions = service.perform

      SuggestionDecorator.decorate_collection(
        @suggestions,
        context: {
          query: query,
          prior_count: prior_count,
          prior_hierarchy: {}#prior_hierarchy.to_hash
        }
      )
    # end
  end
  memoize :results

  class InterfaceProbe 

    def row_classes
      "suggestion cfr_reference"
    end

    def prefer_content_path
      "https://www.yahoo.com"
    end

    def removed
      false
    end

    def highlight_colspan
      2
    end

    def highlighted_citation
      "10 CFR Part 26 Subpart E"
    end

    def usable_highlight
      "Collecting Specimens for <mark>Test</mark>ing"      
    end


    def method_missing(method_name, *args, &block)
      raise NoMethodError, "undefined method `#{method_name}` for #{self}"
    end
  end

  def global_search_path
    documents_search_path(conditions: {term: query})
    # documents_search_path({
    #   search: {
    #     date: date,
    #     query: query
    #   },
    #   prior_hierarchy: prior_hierarchy.to_hash,
    #   prior_count: prior_count
    # })
  end

  def global_search_description
    describe_search_results(global_search_results)
  end

  def narrowed_search_description(narrowed_search_result)
    describe_search_results(
      narrowed_search_result.count,
      narrowed_search_result.omni_search_scope_description
    )
  end

  def narrowed_search_path(narrowed_search_result)
    SearchPresenter::Suggestions.new(Array.wrap(narrowed_search_result)).suggestions.first.path

    # search_path({
    #   search: {
    #     date: date,
    #     query: query,
    #     hierarchy: narrowed_hierarchy.hierarchy_hash
    #   }
    # })
  end

  def overflow_toggle_at_border?
    !total_search_results
  end

  def results?
    results.present? || search_results?
  end

  def search_results?
    global_search_results || narrowed_search_results
  end

  private


  def describe_search_results(count, custom_scope_description = nil)
    if !count || count < 1
      "<span class='no-results'>
        No results found, completing your word or phrase may improve results
      </span>".html_safe
    else
      count_description = (count >= 10_000) ? "10,000+" : number_with_delimiter(count)

      scope_description = custom_scope_description || "in the full text"

      "#{count_description} matching #{"result".pluralize(count)} #{scope_description}".html_safe
    end
  end
end
