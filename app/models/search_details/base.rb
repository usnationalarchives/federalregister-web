class SearchDetails::Base
  attr_reader :conditions

  PLURAL_FILTERS = [
    :agencies,
    :president,
    :presidential_document_type,
    :search_type_ids,
    :sections,
    :small_entity_ids,
    :topics,
    :type,
  ]

  def initialize(conditions={})
    @conditions = conditions
  end

  def suggestions
    return [] unless response.suggestions.present?
    
    @suggestions ||= response.suggestions.map do |type, details|
      SearchSuggestion.build(type, details, conditions)
    end.compact.reverse
  end

  def matching_entry_citation
    suggestions.detect{|x| x.is_a?(SearchSuggestion::Citation)}
  end

  def entry_with_document_number
    suggestions.detect{|x| x.is_a?(SearchSuggestion::DocumentNumber)}
  end

  def filters
    if response.filters.present?
      @filters ||= response.filters.keys.map do |filter_type|
        if PLURAL_FILTERS.include?(filter_type.to_sym)
          response.filters[filter_type].map do |filter|
            Filter.new(filter_type, filter)
          end
        else
          Filter.new(filter_type, response.filters[filter_type])
        end
      end.flatten
    end
  end

  class Filter
    attr_reader :condition, :label, :name, :value
    def initialize(condition, options)
      @condition = condition
      @value = options.delete("value")
      @name = String(options.delete("name"))
      @label = String(options.delete("label"))
    end
  end
end
