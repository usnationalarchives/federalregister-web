class SearchSuggestion::CitationSuggestion < Citation
  include SearchSuggestion::Shared

  attr_reader :conditions

  def initialize(options, conditions)
    @conditions = conditions
    super(options)
  end

  def name
    conditions["term"]
  end

  def citation
    self.superclass.name
  end

end
