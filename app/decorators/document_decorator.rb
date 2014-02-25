class DocumentDecorator < ApplicationDecorator
  delegate_all

  def agency_names(options = {})
    autolink = true unless options[:no_links]

    if agencies.present?
      agencies = model.agencies.map{|a| "the #{h.link_to_if autolink, a.name, a.url}" }
    else
      agencies = model.agencies.map(&:name)
    end

    agencies.to_sentence.html_safe
  end

  def presidential_document?
    type == "Presidential Document"
  end

  def start_page?
    start_page.present? && start_page != 0
  end

  # Tuesday, December 17th, 2013
  def formal_publication_date
    publication_date.to_s(:formal)
  end

  # Dec 17th, 2013
  def shorter_ordinal_signing_date
    signing_date.to_s(:shorter_ordinal)
  end

  def length
    if end_page && start_page
      end_page - start_page + 1
    else
      nil
    end
  end

  def formatted_cfr_references
    cfr_references.map do |cfr|
      str = ["#{cfr["title"]} CFR"]

      if cfr["chapter"].present?
        str << "chapter #{h.number_to_roman(cfr["chapter"])}"
      else
        str << cfr["part"]
      end
      str = str.join(' ')

      if cfr["citation_url"].present?
        h.link_to str, cfr["citation_url"]
      else
        str
      end
    end
  end

  def has_comments?
    regulations_dot_gov_info && regulations_dot_gov_info['comments_count'] > 0
  end
end
