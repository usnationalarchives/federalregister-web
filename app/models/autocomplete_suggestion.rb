class AutocompleteSuggestion < FederalRegister::Base
  add_attribute :document_number,
                :search_term_completion,
                :entry_type

  def self.suggestions(term)
    response = get("/documents/autocomplete-suggestions.json", query: {conditions: {term: term}}).parsed_response

    response.map do |hsh|
      new(hsh, :full => true)
    end
  end

  def icon
    DocumentType.new(entry_type).icon_class
  end

end
