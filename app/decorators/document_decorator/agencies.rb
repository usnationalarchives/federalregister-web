module DocumentDecorator::Agencies
  def agency_name_sentence(options = {})
    agencies = linked_agency_names(options)

    agencies.present? ? agencies.to_sentence.html_safe : ''
  end

  def linked_agency_names(options={})
    autolink = options.fetch(:links){ true }
    definite_article = options.fetch(:definite_article, true)
    name_method = options.fetch(:name_method, :name)

    if agencies.present?
      agencies = document.excluding_parent_agencies.map{|a|
        agency_name = a.send(name_method)
        next if agency_name.nil?

        agency_name = agency_name.downcase.capitalize_most_words if name_method == :raw_name

        "#{definite_article ? 'the' : ''} #{h.link_to_if autolink && a.url.present?, agency_name, a.url}".strip.html_safe
      }.uniq
    elsif agency_names.present?
      agencies = document.agency_names.map
    end

    agencies ? agencies.compact : ""
  end
end
