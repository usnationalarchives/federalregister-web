module DocumentDecorator::Agencies
  def agency_name_sentence(options = {})
    autolink = options.fetch(:no_links){ true }

    if document.agencies.present?
      agencies = document.excluding_parent_agencies.map{|a|
        "the #{h.link_to_if autolink, a.name, h.agency_path(a)}"
      }
    elsif document.agency_names.present?
      agencies = document.agency_names.map
    end

    agencies.present? ? agencies.to_sentence : ''
  end
end
