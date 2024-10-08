module CitationsHelper
  def add_citation_links(html, options = {})
    FederalRegisterReferenceParser.hyperlink_with_fr_defaults(html, options: options)
  end

  def citation_link_with_page_number(document, page_number)
    path = document.html_url
    anchor = page_number.to_i

    if document.start_page.to_i != anchor
      path << "#page-#{anchor}"
    end

    path
  end

  def page_range_with_page_abbreviation_prefix(page_range)
    if page_range.to_s.include?("-")
      "pp. #{page_range}"
    else
      "p. #{page_range}"
    end
  end
end
