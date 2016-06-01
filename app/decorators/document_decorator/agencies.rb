module DocumentDecorator::Agencies
  def agency_name_sentence(options = {})
    agencies = linked_agency_names(options)

    agencies.present? ? agencies.to_sentence.html_safe : ''
  end

  def linked_agency_names(options={})
    autolink = options.fetch(:links){ true }
    definite_article = options.fetch(:definite_article, true)

    if agencies.present?
      agencies = document.excluding_parent_agencies.map{|a|
        next if a.name.nil?

        "#{definite_article ? 'the' : ''} #{h.link_to_if autolink, a.name, a.url}".strip.html_safe
      }
      }.uniq
    elsif agency_names.present?
      agencies = document.agency_names.map
    end

    agencies.compact
  end
end
