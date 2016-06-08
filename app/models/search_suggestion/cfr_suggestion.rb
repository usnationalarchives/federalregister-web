class SearchSuggestion::CFRSuggestion
  include SearchSuggestion::Shared

  attr_reader :conditions, :part, :section, :title

  def initialize(options, conditions)
    @conditions = conditions
    @part = options["part"]
    @section = options["section"]
    @title = options["title"]
  end

  def name
    "#{title} CFR #{part}" + (section.blank? ? '' : ".#{section}")
  end
end
