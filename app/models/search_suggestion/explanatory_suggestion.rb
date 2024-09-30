class SearchSuggestion::ExplanatorySuggestion
  include SearchSuggestion::Shared

  attr_reader :citation, :text, :link_url

  def initialize(options, conditions)
    @conditions = conditions
    @text = options["text"]
    @link_url = options["link_url"]
    @citation = options["citation"]
  end

end
