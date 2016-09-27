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

  # Tuesday, December 17th, 2013
  def formal_publication_date
    publication_date.to_s(:formal)
  end

  def shortened_abstract(length=500)
    h.truncate_words(model.abstract, :length => length) || "<em>[Not available]</em>".html_safe
  end
end
