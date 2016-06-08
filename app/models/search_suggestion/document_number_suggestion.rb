class SearchSuggestion::DocumentNumberSuggestion
  include SearchSuggestion::Shared

  attr_reader :document_number

  def initialize(options, conditions)
    @conditions = conditions
    @document_number = options["document_number"]
  end

  def document
    @document ||= DocumentDecorator.decorate(
      Document.find(document_number)
    )
  end
end
