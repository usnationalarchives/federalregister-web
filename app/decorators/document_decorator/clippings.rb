module DocumentDecorator::Clippings
  def agency_dt_dd
    html = "<dt class=\"agencies\">#{pluralize_without_count(agency_names.size, 'Agency')}:</dt>"
    html = html + agency_dd
    html.html_safe
  end

  def agency_dd
    wrap_in_dd(linked_agency_names(definite_article: false))
  end

  def docket_dt_dd
    html = ""
    if docket_ids.present?
      html = "<dt class=\"dockets\">Agency/Docket #{pluralize_without_count(docket_ids.size, 'Number')}:</dt>\n"
      html = html + docket_dd
    end
    html.html_safe
  end

  def docket_dd
    wrap_in_dd(docket_ids)
  end
end
