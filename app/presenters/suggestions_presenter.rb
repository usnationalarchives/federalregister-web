class SuggestionsPresenter < ApplicationPresenter
  extend Memoist
  include ActionView::Helpers::NumberHelper
  # include SearchPresenter::OfflineTolerant

  attr_reader :service, :suggestions

  delegate :date, :metadata, :prior_count, :prior_hierarchy, :query,
    to: :service, allow_nil: true

  delegate :global_search_results, :narrowed_hierarchy, :narrowed_search_results, :public_inspection_search_results,
    to: :metadata, allow_nil: true

  def initialize(params)
    # VERIFY: don't pass prior_hierarchy along as this is a new request cycle?
    @params = params
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

  def global_search_path
    conditions = {term: query}.tap do |x|
      if agency
        x.merge!(agencies: agency.slug)
      end
    end
    documents_search_path(conditions: conditions)
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

  def pil_search_description(narrowed_search_result)
    count             = narrowed_search_result.count
    count_description = number_with_delimiter(count)

    "#{count_description} #{"public inspection document".pluralize(count)} matching '#{query}'"
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

  def agency
    if params[:agencies]
      Agency.find(params[:agencies].first)
    end
  end
  memoize :agency

  private

  attr_reader :params

  def describe_search_results(count, custom_scope_description = nil)
    if !count || count < 1
      "<span class='no-results'>
        No results found, completing your word or phrase may improve results
      </span>".html_safe
    else
      # count_description = (count >= 10_000) ? "10,000+" : number_with_delimiter(count)
      count_description = number_with_delimiter(count)

      scope_description = custom_scope_description || "in the full text"

      if custom_scope_description
        "#{count_description} #{"document".pluralize(count)} #{scope_description}".
          gsub(/<span\s+class="term">(.*?)<\/span>/, '<span class="term">\'\1\'</span>') # eg Add quotes to term for queries like "10 CFR 2 tort"
      else
        "#{count_description} #{"document".pluralize(count)} matching '#{query}'".tap do |string|
          if agency
            string << " for #{agency.name}"
          end
        end
      end
    end
  end
end
