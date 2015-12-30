module CitationsHelper
  def add_citation_links(html, options = {})
    Hyperlinker.perform(html, options)
  end
end
