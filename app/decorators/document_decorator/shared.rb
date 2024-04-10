module DocumentDecorator::Shared
  def document_type
    @document_type ||= DocumentType.new(model.type)
  end

  # deprecated - use agency_name_sentence in DocumentDecorator::Agencies
  def agency_names(options = {})
    autolink = true unless options[:no_links]

    if agencies.present?
      agencies = model.agencies.map{|a| "the #{h.link_to_if autolink, a.name, a.url}" }
    else
      agencies = model.agencies.map(&:name)
    end

    agencies.to_sentence.html_safe
  end

  # Tuesday, December 17, 2013
  def formal_publication_date
    publication_date.to_s(:formal_wo_ordinal)
  end

  def shortened_abstract(length=500)
    h.truncate_words(model.abstract, :length => length) || "<em>[Not available]</em>".html_safe
  end

    # we mark long titles so that we can reduce their font size
    def title_class
      case title.size
      when 0..115
        ""
      when 116..300
        "large-title"
      when 301..600
        "extra-large-title"
      else
        "jumbo-title"
      end
    end
end
