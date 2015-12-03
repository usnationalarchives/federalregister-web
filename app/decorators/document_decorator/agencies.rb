module DocumentDecorator::Agencies
  def agency_name_sentence(options = {})
    autolink = options.fetch(:no_links){ true }

    if document.agencies.present?
      agencies = document.excluding_parent_agencies.map{|a|
        next if a.name.nil?

        "the #{h.link_to_if autolink, a.name, a.url}"
      }
    elsif document.agency_names.present?
      agencies = document.agency_names.map
    end

    agencies.present? ? agencies.compact.to_sentence.html_safe : ''
  end
end
