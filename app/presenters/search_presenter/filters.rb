class SearchPresenter::Filters
  include Rails.application.routes.url_helpers

  attr_accessor :search_conditions, :search_params
  def initialize(filters, search_params)
    @filters = filters
    @search_params = search_params
    @search_conditions = search_params[:conditions].with_indifferent_access
  end

  # these fields are now always displayed and so a filter notification
  # is not neccessary
  HIDDEN_FILTERS = %w[agencies type]

  def filters
    @filters.group_by(&:condition).sort_by{|k,v| k}.map do |condition, filters|
      next if HIDDEN_FILTERS.include?(filters.first.condition)
        filters.each_with_index.map do |filter, index|
          text = h.content_tag(:p) do
            content = []
            if index > 0
              content << h.content_tag(:span, "or", class: "filter-connector")
            end

            content << filter.name

            content.join("\n").html_safe
          end

          ContentNotification.new(
            text: text,
            link: h.link_to("Remove Filter",
              remove_search_filter_path(filter.condition.to_sym, filter.value)
            ),
            type: :warning,
            icon: 'filter',
            icon_label: filters.first.label,
            options: {html: {class: "with-icon-label"}}
          )
        end
    end.flatten.compact
  end

  private

  def h
    ActionController::Base.helpers
  end

  def remove_search_filter_path(condition, value)
    revised_conditions = search_conditions.deep_dup

    if SearchDetails::Base::PLURAL_FILTERS.include?(condition)
      revised_conditions[condition] ||= []
      revised_conditions[condition] = revised_conditions[condition] - Array(value.to_s)
    else
      revised_conditions.except!(condition)
    end

    documents_search_path(
      search_params
        .except(:quiet)
        .merge(page: nil, action: :show, conditions: revised_conditions)
    )
  end
end
