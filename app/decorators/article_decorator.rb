class ArticleDecorator < ApplicationDecorator
  def granule_class
    case model.type
    when 'Rule'
      'rule'
    when 'Proposed Rule'
      'proposed_rule'
    when 'Notice'
      'notice'
    when 'Presidential Document'
      'presidential_document'
    when 'Uncategorized Document'
      'uncategorized'
    when 'Sunshine Act Document'
      'notice'
    when 'Correction'
      'correct'
    end
  end

  def publication_date
    model.publication_date
  end

  def publication_date_formally
    model.publication_date.to_formatted_s(:formal)
  end

  def effective_date
    model.effective_on if model.effective_on
  end

  def shortened_abstract(length=500)
    h.truncate_words(model.abstract, :length => length) || "[No abstract available]"
  end

  def agency_dt_dd
    html = "<dt class=\"agencies\">#{pluralize_without_count(agency_names.size, 'Agency')}:</dt>"
    html = html + agency_dd
    html.html_safe
  end

  def agency_dd
    wrap_in_dd(agency_names(:the => false))
  end

  def pages
    if model.end_page.present? && model.start_page.present?
      model.end_page - model.start_page + 1
    else
      ""
    end
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

  def comments_close_date
    model.comments_close_on if model.comments_close_on
  end

  def signing_date
    model.signing_date if model.signing_date
  end

  def corrected_by
    document_numbers = model.corrections.map{|url| url.split('/').last.split('.').first}
    document_numbers.map do |d|
      h.content_tag(:dd, h.link_to(d, "https://www.federalregister.gov/a/#{d}"))
    end.join("\n").html_safe
  end

  def corrects
    document_number = model.correction_of.split('/').last.split('.').first
    h.link_to(document_number, "https://www.federalregister.gov/a/#{document_number}")
  end

  def short_article_url
    "https://www.federalregister.gov/a/#{document_number}"
  end

  def agency_names(options = {})
    autolink = options.has_key?(:links) ? options[:links] : true
    include_the = options.has_key?(:the) ? options[:links] : true

    if model.agencies.select{|x| x.id}.present?
      parent_ids = model.agencies.map{|x| x.parent_id}.compact
      agencies = model.agencies.
        reject{|x| x.id.nil?}.
        reject{|x| parent_ids.include?(x.id)}.
        map{|a| h.link_to_if autolink, agency_name(a, include_the), a.url }
    else
      agencies = model.agencies.map{|a| agency_name(a, include_the) }
    end
    agencies
  end

  def agency_names_as_sentence(options={})
    agency_names(options).to_sentence.html_safe
  end

  def regulations_dot_gov_comment_count
    (regulations_dot_gov_info && regulations_dot_gov_info["comments_count"]) || 0
  end

  def regulations_dot_gov_docket_id
    (regulations_dot_gov_info && regulations_dot_gov_info["docket_id"])
  end

  def regulations_dot_gov_docket_title
    (regulations_dot_gov_info && regulations_dot_gov_info["title"])
  end

  def regulations_dot_gov_docket_url
    "https://www.regulations.gov/docketDetail?D=#{regulations_dot_gov_docket_id}"
  end


  def regulations_dot_gov_comments_url
    if regulations_dot_gov_docket_id
      "https://www.regulations.gov/docketBrowser?dct=PS&rpp=50&po=0&D=#{regulations_dot_gov_docket_id}"
    end
  end

  private

  def agency_name(agency, include_the)
    if include_the
      "the #{agency.name}"
    else
      agency.name
    end
  end
end
