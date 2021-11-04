module CitationsHelper
  def add_citation_links(html, options = {})
    FederalRegisterReferenceParser.hyperlink_with_fr_defaults(html, options: options)
  end
end
