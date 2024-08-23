class SuggestionsPresenter < ApplicationPresenter
  extend Memoist
  # include SearchPresenter::OfflineTolerant #TODO: Figure out what this is for

  attr_reader :service

  delegate :query, :prior_count, :prior_hierarchy, to: :service, allow_nil: true

  def initialize(params)
    @service = SuggestionService.new(params.except(:prior_hierarchy))
  end

  def results
    guard_search_offline do
      SuggestionDecorator.decorate_collection(
        service.perform,
        context: {
          query: query,
          prior_count: prior_count,
          prior_hierarchy: prior_hierarchy
        }
      )
    end
  end
  memoize :results

  def results_without_search_results
    results.select { |r| !r.search_suggestion? }
  end

  def search_results
    results.select { |r| r.search_suggestion? }
  end

  def total_search_results
    search_results.detect { |r| r.kind == :total_search_results }
  end

  def total_hierarchy_search_results
    search_results.detect { |r| r.kind == :total_hierarchy_search_results }
  end

  def overflow_toggle_at_border?
    !total_search_results
  end

  def results?
    results&.present?
  end
end
