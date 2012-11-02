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
    when 'Sunshine Act Document'
      'notice'
    when 'Correction'
      'correct'
    end
  end

  def publication_date
    model.publication_date.to_formatted_s(:date)
  end

  def publication_date_formally
    model.publication_date.to_formatted_s(:formal)
  end

  def effective_date
    model.effective_on.to_formatted_s(:date) if model.effective_on
  end

  def shortened_abstract
    h.truncate_words(model.abstract, :length => 500) || "[No abstract available]"
  end

  def agency_dt_dd
    html = "<dt class=\"agencies\">#{pluralize_without_count(model.agencies.size, 'Agency')}:</dt>"
    html = html + agency_dd
    html.html_safe
  end

  def agency_dd
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

  def comments_close_date
    model.comments_close_on.to_formatted_s(:date) if model.comments_close_on
  end

  def signing_date
    model.signing_date.to_formatted_s(:date)
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
    if model.agencies.select{|x| x.id}.present?
      parent_ids = model.agencies.map{|x| x.parent_id}.compact
      agencies = model.agencies.
        reject{|x| x.id.nil?}.
        reject{|x| parent_ids.include?(x.id)}.
        map{|a| "the #{h.link_to_if autolink, a.name, a.url}" }
    else
      agencies = model.agencies.map{|a| "the #{a.name}"}
    end
    agencies
  end

  def agency_names_as_sentence(options={})
    agency_names(options).to_sentence.html_safe
  end
end
