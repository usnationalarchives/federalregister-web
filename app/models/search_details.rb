class SearchDetails
  attr_reader :conditions

  PLURAL_FILTERS = [:agencies, :topics, :type]

  def initialize(conditions={})
    @conditions = conditions
  end

  def response
    @response ||= HTTParty.get(
      "#{Settings.federal_register.api_url}/documents/search-details?#{{conditions: valid_search_detail_conditions}.to_param}"
    )
  end

  def suggestions
    return [] unless response["suggestions"].present?
    
    @suggestions ||= response["suggestions"].map do |type, details|
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
    if response["filters"].present?
      @filters ||= response["filters"].keys.map do |filter_type|
        if PLURAL_FILTERS.include?(filter_type.to_sym)
          response["filters"][filter_type].map do |filter|
            Filter.new(filter_type, filter)
          end
        else
          Filter.new(filter_type, response["filters"][filter_type])
        end
      end.flatten
    end
  end

  def valid_search_detail_conditions
    @conditions.except(:special_filing)
  end

  class Filter
    attr_reader :value, :condition, :name_or_names
    def initialize(condition, options)
      @condition = condition
      @value = options.delete("value")
      @name_or_names = options.delete("name")
    end

    def name
      if name_or_names.is_a?(Array)
        name_or_names.join(", ")
      else
        String(name_or_names)
      end
    end
  end
end
