class DocumentDecorator < ApplicationDecorator
  delegate_all

  def agency_names(options = {})
    autolink = true unless options[:no_links]

    if model.agencies.present?
      agencies = model.agencies.map{|a| "the #{h.link_to_if autolink, a.name, a.url}" }
    else
      agencies = model.agencies.map(&:name)
    end

    agencies.to_sentence.html_safe
  end

  def formatted_publication_date
    model.publication_date.to_s(:date)
  end

  def iso_publication_date
    model.publication_date.to_s(:iso)
  end
end
