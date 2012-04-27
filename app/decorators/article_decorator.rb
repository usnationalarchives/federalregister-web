class ArticleDecorator < ApplicationDecorator
  def granule_class
    case model.type
    when 'Rule'
      'rule'
    when 'Proposed Rule'
      'prorule'
    when 'Notice'
      'notice'
    when 'Presidential Document'
      'presdocu'
    when 'Document of Unknown Type'
      'unknown'
    end
  end

  def publication_date
    model.publication_date.to_formatted_s(:date)
  end

  def agency_dt_dd
    html = "<dt class=\"agencies\">#{pluralize_without_count(model.agencies.size, 'Agency')}:</dt>"
    html = html + agency_dd
    html.html_safe
  end

  def agency_dd
    agency_names = model.agencies.map{|a| a.name}
    wrap_in_dd(agency_names)
  end

  def pages
    model.end_page - model.start_page + 1
  end

  def docket_dt_dd
    html = ""
    if model.docket_ids.present?
      html = "<dt class=\"dockets\">Agency/Docket #{pluralize_without_count(model.docket_ids.size, 'Number')}:</dt>\n"
      html = html + docket_dd
    end
    html.html_safe
  end

  def docket_dd
    wrap_in_dd(model.docket_ids)
  end


  def fr_citation
    "#{model.volume} FR #{model.start_page}"
  end
end
