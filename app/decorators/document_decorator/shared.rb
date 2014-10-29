module DocumentDecorator::Shared
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

  def display_type
    model.
      type.
      split(" ").
      map(&:capitalize).
      join(" ")
  end

  def agency_names(options = {})
    autolink = true unless options[:no_links]

    if agencies.present?
      agencies = model.agencies.map{|a| "the #{h.link_to_if autolink, a.name, a.url}" }
    else
      agencies = model.agencies.map(&:name)
    end

    agencies.to_sentence.html_safe
  end

  # Tuesday, December 17th, 2013
  def formal_publication_date
    publication_date.to_s(:formal)
  end
end
