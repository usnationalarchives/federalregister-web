class RSSUrlBuilder
  attr_reader :base_url, :identifier, :options

  def initialize(identifier)
    @identifier = identifier
  end

  def base_url
    @base_url = "https://www.#{Settings.rss_helper.url}/documents/search.rss?"
  end

  def options
    "conditions[sections]=#{identifier}&order=newest"
  end

  def url
    base_url + options.to_s
  end
end
