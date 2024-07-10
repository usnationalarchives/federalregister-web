class SearchSuggestion::ExplanatorySuggestion
  include SearchSuggestion::Shared

  attr_reader :text, :link_url

  def initialize(options, conditions)
    @conditions = conditions
    @text = options["text"]
    @link_url = options["link_url"]
  end

end
